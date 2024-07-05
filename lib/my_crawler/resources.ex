defmodule MyCrawler.Resource do
  use Ecto.Schema
  import Ecto.Changeset

  schema "resources" do
    field(:data, :string)
    field(:md5_hash, :string)
  end

  # 定义 changest
  def changeset(attrs, params \\ %{}) do
    attrs
    |> cast(params, [:data, :md5_hash])
    |> validate_required([:data, :md5_hash])
  end
end
