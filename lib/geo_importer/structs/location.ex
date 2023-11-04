defmodule GeoImporter.Structs.Location do
  @moduledoc """
  Schema reflecting geolocation data. The structure used for representing imported data.
  """
  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          ip_address: Postgrex.INET.t(),
          country_code: String.t(),
          country: String.t(),
          city: String.t(),
          lon: Decimal.t(),
          lat: Decimal.t(),
          code: pos_integer()
        }

  schema "locations" do
    field(:ip_address, EctoNetwork.INET)
    field(:country_code, :string)
    field(:country, :string)
    field(:city, :string)
    field(:lon, :decimal)
    field(:lat, :decimal)
    field(:code, :integer)

    timestamps()
  end

  @lon_maximum 180
  @lat_maximum 90
  @country_code_iso_length 2
  @required_fields ~w(ip_address country_code country city lon lat code)a

  @spec insert_changeset(map()) :: Ecto.Changeset.t()
  def insert_changeset(params) do
    %__MODULE__{}
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> validate_length(:country_code, is: @country_code_iso_length)
    |> validate_coordinate(:lon, @lon_maximum)
    |> validate_coordinate(:lat, @lat_maximum)
  end

  defp validate_coordinate(changeset, field, number) do
    validate_change(changeset, field, fn _field_name, %Decimal{} = data ->
      case {Decimal.compare(data, number), Decimal.compare(data, -number)} do
        {max, min} when max == :gt or min == :lt -> ["#{field}": "invalid value"]
        _ -> []
      end
    end)
  end
end
