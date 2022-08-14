defmodule Shift73k.Repo.Migrations.FixShiftsUserIdReference do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE shifts DROP CONSTRAINT shifts_user_id_fkey")

    alter table(:shifts) do
      modify :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
    end
  end

  def down do
    execute("ALTER TABLE shifts DROP CONSTRAINT shifts_user_id_fkey")

    alter table(:shifts) do
      modify :user_id, references(:users, on_delete: :nothing, type: :binary_id)
    end
  end
end
