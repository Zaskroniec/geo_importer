Application.ensure_all_started(:postgrex)

GeoImporter.Test.Repo.start_link()
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GeoImporter.Test.Repo, :manual)
