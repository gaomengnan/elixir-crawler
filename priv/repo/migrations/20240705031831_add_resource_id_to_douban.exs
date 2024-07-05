defmodule MyCrawler.Repo.Migrations.AddResourceIdToDouban do
  use Ecto.Migration

  def change do
   alter table(:douban) do
      add :resource_id, references(:resources, on_delete: :nothing)
   end

   create index(:douban, [:resource_id])
  end
end
