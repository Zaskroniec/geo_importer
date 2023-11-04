defmodule GeoImporter.LocationQueryTest do
  use ExUnit.Case

  alias GeoImporter.Test.Repo
  alias GeoImporter.LocationQuery
  alias GeoImporter.Structs.Location

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "get_by_ip_address!/1" do
    test "returns location by given `ip_address` as binary", %{} do
      %{
        ip_address: "127.0.0.1",
        country_code: "PL",
        country: "Poland",
        city: "Gdańsk",
        lon: "18.638306",
        lat: "54.372158",
        code: 32214
      }
      |> Location.insert_changeset()
      |> Repo.insert!()

      %Location{ip_address: %Postgrex.INET{address: {127, 0, 0, 1}}} =
        LocationQuery.get_by_ip_address!("127.0.0.1")
    end

    test "returns location by given `ip_address` as tuple", %{} do
      %{
        ip_address: "127.0.0.1",
        country_code: "PL",
        country: "Poland",
        city: "Gdańsk",
        lon: "18.638306",
        lat: "54.372158",
        code: 32214
      }
      |> Location.insert_changeset()
      |> Repo.insert!()

      %Location{ip_address: %Postgrex.INET{address: {127, 0, 0, 1}}} =
        LocationQuery.get_by_ip_address!({127, 0, 0, 1})
    end

    test "raises exception for given valid `ip_address`", %{} do
      assert_raise Ecto.NoResultsError, fn ->
        LocationQuery.get_by_ip_address!("127.0.0.1")
      end
    end

    test "raises exception for given invalid `ip_address`", %{} do
      assert_raise Ecto.NoResultsError, fn ->
        LocationQuery.get_by_ip_address!("invalid")
      end
    end
  end
end
