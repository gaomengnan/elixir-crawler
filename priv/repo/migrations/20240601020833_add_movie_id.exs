defmodule MyCrawler.Repo.Migrations.AddMovieId do
  use Ecto.Migration

  def change do
    alter table(:douban) do
      add :movie_id, :integer
    end
  end
end
