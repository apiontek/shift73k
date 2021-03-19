defmodule Shift73k.Repo.Migrations.CreateShiftTemplates do
  use Ecto.Migration

  def change do
    create table(:shift_templates, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject, :string, size: 280, null: false
      add :location, :string, size: 280
      add :description, :text
      add :time_zone, :string, null: false
      add :time_start, :time, null: false
      add :time_end, :time, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:shift_templates, [:user_id, :subject])
  end
end
