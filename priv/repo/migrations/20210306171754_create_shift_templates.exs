defmodule Shift73k.Repo.Migrations.CreateShiftTemplates do
  use Ecto.Migration

  def change do
    create table(:shift_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :label, :string
      add :subject, :string, null: false
      add :description, :string
      add :location, :string
      add :timezone, :string, null: false
      add :start_time, :time, null: false
      add :length_hours, :integer, null: false
      add :length_minutes, :integer
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:shift_templates, [:user_id])
  end
end
