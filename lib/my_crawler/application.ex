defmodule MyCrawler.Application do
  use Application

  def start(_start_type, _start_args) do
    children = [
      {MyCrawler.Repo, []}
      # {MyCrawler.Crawler, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
