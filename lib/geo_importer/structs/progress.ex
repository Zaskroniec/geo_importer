defmodule GeoImporter.Structs.Progress do
  @moduledoc """
  The structure used for representing import statistics.
  """

  @type t :: %__MODULE__{
          total_count: pos_integer(),
          rejected_count: pos_integer(),
          accepted_count: pos_integer(),
          execution_time: pos_integer()
        }

  defstruct total_count: 0, rejected_count: 0, accepted_count: 0, execution_time: 0

  @doc """
  Outputs text that includes:

  * `total_count` - all rows from cv taken into import process
  * `rejected_count` - rows rejected due to incorrect data, validation schema errors
  * `accepted_count` - rows saved into DB
  * `execution_time` - overall time taken to process whole data from CSV (miliseconds)


      iex> GeoImporter.Structs.Progress.message(%GeoImporter.Structs.Progress{})
      iex> "Total time taken during processing all batches in milliseconds: 0,
      ...>  Total number of records processed during import: 0,
      ...>  Records accepted: 0,
      ...>  Records rejected due to validation errors or duplicated rows: 0"
  """
  @spec message(__MODULE__.t()) :: String.t()
  def message(%__MODULE__{} = progress) do
    """
    Total time taken during processing all batches in milliseconds: #{progress.execution_time},
    Total number of records processed during import: #{progress.total_count}
    Records accepted: #{progress.accepted_count},
    Records rejected due to validation errors or duplicated rows: #{progress.rejected_count}
    """
  end
end
