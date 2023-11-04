import Config

config :geo_importer, GeoImporter.Test.Repo,
  migration_lock: false,
  name: Oban.Test.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10,
  priv: "test/support/postgres",
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: System.get_env("DB_NAME") || "geo_importer_test"

config :geo_importer,
  ecto_repos: [GeoImporter.Test.Repo]

config :geo_importer, repo: GeoImporter.Test.Repo

config :logger, level: :warning
