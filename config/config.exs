import Config

config :my_crawler, MyCrawler.Repo,
  database: "douban_crawler",
  username: "postgres",
  password: "Root123456",
  hostname: "localhost"

config :my_crawler, ecto_repos: [MyCrawler.Repo]
