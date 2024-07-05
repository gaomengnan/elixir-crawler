defmodule MyCrawler.Douban do
  use Ecto.Schema

  import Ecto.Changeset

  schema "douban" do
    field(:movie_id, :integer)
    field(:title, :string)
    field(:url, :string)
    field(:rank, :integer)
    field(:score, :float)
    field(:comment_count, :integer)
    field(:cover, :string)
    field(:desc, :string)
    # field(:resource_id, :id)
    belongs_to(:resource, MyCrawler.Resource, foreign_key: :resource_id, references: :id)
  end

  # 定义 changest
  def changeset(attrs, params \\ %{}) do
    attrs
    |> cast(params, [
      :title,
      :url,
      :rank,
      :score,
      :comment_count,
      :cover,
      :desc,
      :movie_id,
      :resource_id
    ])
    |> validate_required([:title, :url, :rank, :score, :comment_count, :cover, :desc, :movie_id])
    |> foreign_key_constraint(:resource_id)
  end
end
