defmodule GeoImporter.LocationQuery do
  @moduledoc """
  Module responsible for fetching %GeoImporter.Structs.Location{} row from DB.
  """
  import Ecto.Query

  alias GeoImporter.Structs.Location

  @doc """
  Fetch row for given ip_address as binary or tuble. Function raises exception
  wheneaver row cannot be found or ip_address cannot be casted into Postgrex.INET.t().

  # Correct example:

      iex> GeoImporter.LocationQuery.get_by_ip_address!("127.0.0.1")
      iex> %GeoImporter.Structs.Location{}

      iex> GeoImporter.LocationQuery.get_by_ip_address!({127, 0, 0, 1})
      iex> %GeoImporter.Structs.Location{}

  # Invalid argument type example:

      iex> GeoImporter.LocationQuery.get_by_ip_address!([127, 0, 0, 1])
      iex> :error

  """
  @spec get_by_ip_address!(binary() | tuple()) :: Location.t() | :error
  def get_by_ip_address!(ip_address) when is_binary(ip_address) or is_tuple(ip_address) do
    repo = Application.get_env(:geo_importer, :repo)
    ip_address = cast_ip_address(ip_address)

    Location
    |> from(as: :locations)
    |> where([locations: l], l.ip_address == ^ip_address)
    |> repo.one!()
  end

  def get_by_ip_address!(_), do: :error

  defp cast_ip_address(ip_address) do
    case EctoNetwork.INET.cast(ip_address) do
      {:ok, ip_address} -> ip_address
      :error -> raise Ecto.NoResultsError, queryable: Location
    end
  end
end
