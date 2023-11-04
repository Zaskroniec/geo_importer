defmodule GeoImporter.Importer do
  @moduledoc """
  Module responsile for processing CV file and extracting geo localizations
  """
  alias GeoImporter.Structs.{Location, Progress}

  require Logger

  @batch_size 500

  @type optional_integer :: pos_integer() | nil

  @doc """
  Process CV file and save each row into DB. Each batch contains at most 500 rows.
  Support option to process small part of the csv by providing limit option as argument.

  # Example

      ex> GeoImporter.Importer.process("test/support/sample_dump.csv")
      ex> %GeoImporter.Structs.Progress{}

  # Example with limitted import

      ex> GeoImporter.Importer.process("test/support/sample_dump.csv", 5)
      ex> %GeoImporter.Structs.Progress{}
  """
  @spec process(String.t(), optional_integer()) :: Process.t()
  def process(file_path, limit \\ nil) do
    Logger.info("Starting import process ...")

    repo = Application.get_env(:geo_importer, :repo)
    start_time = DateTime.utc_now()
    timestamp = get_timestamp()

    result =
      file_path
      |> File.stream!()
      |> CSV.decode!(headers: true, separator: ?,)
      |> maybe_limit_process(limit)
      |> Stream.chunk_every(@batch_size)
      |> Stream.map(fn rows ->
        batch_count = length(rows)
        dataset = build_dataset(rows)
        placeholders = %{timestamp: timestamp}

        {accepted_count, _} =
          repo.insert_all(
            Location,
            dataset,
            on_conflict: :nothing,
            conflict_target: :ip_address,
            placeholders: placeholders
          )

        rejected_count = batch_count - accepted_count

        %{
          batch_count: batch_count,
          rejected_count: rejected_count,
          accepted_count: accepted_count
        }
      end)
      |> Enum.reduce(%Progress{}, fn item, acc ->
        %Progress{
          acc
          | total_count: acc.total_count + item.batch_count,
            rejected_count: acc.rejected_count + item.rejected_count,
            accepted_count: acc.accepted_count + item.accepted_count
        }
      end)

    execution_time = DateTime.diff(DateTime.utc_now(), start_time, :millisecond)
    result = %Progress{result | execution_time: execution_time}

    Logger.info("Finished import. See stats: \n#{Progress.message(result)}")

    result
  end

  defp maybe_limit_process(stream, limit) when is_number(limit), do: Stream.take(stream, limit)
  defp maybe_limit_process(stream, _limit), do: stream

  defp build_dataset(rows) do
    rows
    |> Enum.map(fn row ->
      row
      |> filter_values()
      |> build_params()
      |> Location.insert_changeset()
    end)
    |> Enum.filter(& &1.valid?)
    |> Enum.map(fn changeset ->
      Map.merge(changeset.changes, %{
        inserted_at: {:placeholder, :timestamp},
        updated_at: {:placeholder, :timestamp}
      })
    end)
  end

  defp filter_values(row) do
    row
    |> Enum.filter(fn {_k, v} -> v != "" end)
    |> Enum.map(fn {k, v} -> {k, HtmlSanitizeEx.strip_tags(v)} end)
    |> Enum.into(%{})
  end

  defp build_params(row) do
    %{
      "ip_address" => row["ip_address"],
      "country_code" => row["country_code"],
      "country" => row["country"],
      "city" => row["city"],
      "lon" => row["longitude"],
      "lat" => row["latitude"],
      "code" => row["mystery_value"]
    }
  end

  defp get_timestamp() do
    NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
  end
end
