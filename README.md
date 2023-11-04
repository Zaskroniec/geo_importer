# GeoImporter

## Requirements

GeoImporter requires Elixir v1.15+, Erlang 26.1+ and PostgreSQL 15.3+

## Installation

```elixir
def deps do
  [
    {:geo_importer, "~> 0.1.0", git: "https://github.com/Zaskroniec/geo_importer"}
  ]
end
```

Then run `mix deps.get` to install GeoImporter and its dependencies. See `mix.exs` to check all installed dependencies.

After the packages are installed you must create a database migration to add the  table to your database:

```bash
mix ecto.gen.migration create_locations
```

Once migration is generated, edit it and put:

```elixir
defmodule MyApp.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table("locations") do
      add :ip_address, :inet, null: false
      add :country_code, :string, size: 2, null: false
      add :country, :string, null: false
      add :city, :string, null: false
      add :lon, :decimal, null: false, precision: 15, scale: 12
      add :lat, :decimal, null: false, precision: 15, scale: 13
      add :code, :bigint, null: false

      timestamps()
    end

    create unique_index(:locations, :ip_address)
  end
end
```

Setup your Ecto Repo in application and put in `config/config.exs`:

```elixir
:geo_importer, repo: MyApp.Repo
```

Now you should be ready to go!

## Usage

```elixir
# Fetching Location row from db:
GeoImporter.LocationQuery.get_by_ip_address!("127.0.0.1")

# Running importer for given CSV file:
GeoImporter.LocationQuery.process("path_to_file")

# Running importer for given limited CSV file:
GeoImporter.LocationQuery.process("path_to_file", 10)

# Available structs:
%GeoImporter.Structs.Progress{}
%GeoImporter.Structs.Location{}
```

## Development

1. Setup your DB and adjust environment variables in `config/config.exs`
    1. As alternative of local PostgreSQL dependency use predefined docker-compose setup.
1. Run `mix test` to check if everything pass.
1. Development should be done only on `:test` env

