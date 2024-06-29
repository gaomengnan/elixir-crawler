defmodule MyCrawler.Repo do
  use Ecto.Repo,
    otp_app: :my_crawler,
    adapter: Ecto.Adapters.Postgres
end
