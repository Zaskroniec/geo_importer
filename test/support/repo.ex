defmodule GeoImporter.Test.Repo do
  use Ecto.Repo,
    otp_app: :geo_importer,
    adapter: Ecto.Adapters.Postgres
end
