defmodule Mix.Tasks.RunCrawler do
  use Mix.Task
  alias MyCrawler

  @shortdoc "Run the crawler"
  def run(args) do
    Mix.Task.run("app.start")
    MyCrawler.Repo.start_link()
    url = List.first(args) || "https://example.com"
    MyCrawler.run(url)
  end
end
