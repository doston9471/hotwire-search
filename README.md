# README

This simple project contains [**Hotwire**](https://hotwired.dev/) instant search with [**ransack**](https://activerecord-hackery.github.io/ransack/) gem and infinite pagination with [**pagy**](https://ddnexus.github.io/pagy/) gem

## Project contains:

* Ruby - 4.0.5
* Rails - 8.1
* PostgreSQL
* Redis
* Ransack
* Pagy

## Run with Docker (recommended)

You only need [Docker](https://docs.docker.com/get-docker/) installed.

```bash
docker compose up --build
```

Then open [http://localhost:3000](http://localhost:3000).

On first boot the app waits for Postgres, runs migrations, and seeds sample posts automatically.

Useful commands:

```bash
# Rebuild after Gemfile changes
docker compose up --build

# Rails console
docker compose exec web bin/rails console

# Re-seed posts
docker compose exec web bin/rails db:seed

# Run specs
docker compose exec -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/hotwire_search_test web bin/rails db:prepare
docker compose exec -e RAILS_ENV=test -e DATABASE_URL=postgres://postgres:postgres@db:5432/hotwire_search_test web bundle exec rspec

# Stop everything
docker compose down
```

## Run locally (without Docker)

Requires Ruby 4.0.5, PostgreSQL, and Redis.

```bash
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the [MIT License](LICENSE).
