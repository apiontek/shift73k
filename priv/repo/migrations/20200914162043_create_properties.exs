defmodule Shift73k.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:name, :string)
      add(:price, :decimal)
      add(:description, :text)
      add(:user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:properties, [:user_id]))
  end
end
