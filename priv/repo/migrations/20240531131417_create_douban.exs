defmodule MyCrawler.Repo.Migrations.CreateDouban do
  use Ecto.Migration

  def change do
    create table(:douban) do
      add :title, :string
      add :url, :string
      add :rank, :integer
      add :score, :float
      add :comment_count, :integer
      add :cover, :string
      add :desc, :string
    end
  end
end
