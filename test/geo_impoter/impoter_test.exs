defmodule GeoImporter.ImpoterTest do
  use ExUnit.Case

  import Ecto.Query, only: [where: 2]

  alias GeoImporter.Test.Repo
  alias GeoImporter.Importer
  alias GeoImporter.Structs.{Location, Progress}

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

  describe "process/2" do
    test "process chunk of csv file with limit option and returns progress result" do
      result = Importer.process("test/support/sample_dump.csv", 5)

      assert %Progress{
               total_count: 5,
               rejected_count: 1,
               accepted_count: 4,
               execution_time: execution_time
             } = result

      assert execution_time > 0
      assert 4 = Repo.aggregate(Location, :count, :id)
    end

    test "process chunk of csv file with sanitization" do
      result = Importer.process("test/support/sample_dump.csv", 1)

      assert %Progress{
               total_count: 1,
               rejected_count: 0,
               accepted_count: 1,
               execution_time: execution_time
             } = result

      assert execution_time > 0
      assert 1 = Repo.aggregate(Location, :count, :id)

      location_exists? =
        Location
          |> where(country_code: "SI")
          |> Repo.exists?()

      assert location_exists?
    end

    test "process whole csv file without limit option and returns progress result" do
      result = Importer.process("test/support/sample_dump.csv")

      assert %Progress{
               total_count: 9,
               rejected_count: 1,
               accepted_count: 8,
               execution_time: execution_time
             } = result

      assert execution_time > 0
      assert 8 = Repo.aggregate(Location, :count, :id)
    end
  end
end
