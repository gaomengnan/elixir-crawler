defmodule MyCrawler.Repo.Migrations.CreateResources do
  use Ecto.Migration

  def change do
    create table(:resources) do
      add :data, :text
      add :md5_hash, :string
    end
  end
end
