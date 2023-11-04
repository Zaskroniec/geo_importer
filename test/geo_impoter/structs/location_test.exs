defmodule GeoImporter.Structs.LocationTest do
  use ExUnit.Case

  alias GeoImporter.Structs.Location

  describe "insert_changeset/1" do
    test "builts valid changeset for given params" do
      params = build_params()
      changeset = Location.insert_changeset(params)

      assert changeset.valid?
    end

    test "builts invalid changeset for given empty params" do
      changeset = Location.insert_changeset(%{})

      refute changeset.valid?

      assert [
               ip_address: {"can't be blank", _},
               country_code: {"can't be blank", _},
               country: {"can't be blank", _},
               city: {"can't be blank", _},
               lon: {"can't be blank", _},
               lat: {"can't be blank", _},
               code: {"can't be blank", _}
             ] = changeset.errors
    end

    test "builds invalid changeset for given incorrect ip_address" do
      params = build_params(%{ip_address: "x"})
      changeset = Location.insert_changeset(params)

      refute changeset.valid?

      assert [ip_address: {"is invalid", _}] = changeset.errors
    end

    test "builds invalid changeset for given incorrect `lat` & `lon`" do
      params = build_params(%{lat: "91", lon: "-181"})
      changeset = Location.insert_changeset(params)

      refute changeset.valid?

      assert [
               lat: {"invalid value", _},
               lon: {"invalid value", _}
             ] = changeset.errors

      params = %{params | lat: "-91", lon: "181"}
      changeset = Location.insert_changeset(params)

      refute changeset.valid?

      assert [
               lat: {"invalid value", _},
               lon: {"invalid value", _}
             ] = changeset.errors
    end

    test "builds invalid changeset for given incorrect `country_code`" do
      params = build_params(%{country_code: "POL"})
      changeset = Location.insert_changeset(params)

      refute changeset.valid?

      assert [country_code: {"should be %{count} character(s)", _}] = changeset.errors
    end

    defp build_params(params \\ %{}) do
      %{
        ip_address: "127.0.0.1",
        country_code: "PL",
        country: "Poland",
        city: "Gdańsk",
        lon: "18.638306",
        lat: "54.372158",
        code: 32214
      }
      |> Map.merge(params)
    end
  end
end
