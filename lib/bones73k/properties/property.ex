defmodule Bones73k.Properties.Property do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "properties" do
    field :description, :string
    field :name, :string
    field :price, :decimal
    field :user_id, :binary_id

    timestamps()
  end

  def create_changeset(property, attrs) do
    property
    |> cast(attrs, [:name, :price, :description, :user_id])
    |> validate_required([:name, :price, :description, :user_id])
  end

  @doc false
  def changeset(property, attrs) do
    property
    |> cast(attrs, [:name, :price, :description])
    |> validate_required([:name, :price, :description])
  end
end
