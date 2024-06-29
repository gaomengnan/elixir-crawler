defmodule MyCrawler.Repo.Migrations.AddMovieIdUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:douban, [:movie_id])
  end
end
