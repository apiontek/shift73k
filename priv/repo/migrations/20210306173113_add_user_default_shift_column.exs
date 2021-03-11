defmodule Shift73k.Repo.Migrations.AddUserDefaultShiftColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:fave_shift_template_id, references(:shift_templates, type: :binary_id, on_delete: :delete_all))
    end
  end
end
