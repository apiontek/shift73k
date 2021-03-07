defmodule Shift73k.ShiftTemplates.ShiftTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @app_vars Application.get_env(:shift73k, :app_global_vars, time_zone: "America/New_York")
  @time_zone @app_vars[:time_zone]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shift_templates" do
    field :label, :string
    field :subject, :string, default: "My Work Shift"
    field :description, :string
    field :location, :string
    field :timezone, :string, default: @time_zone
    field :start_time, :time, default: ~T[09:00:00]
    field :length_hours, :integer, default: 8
    field :length_minutes, :integer, default: 0

    belongs_to(:user, Shift73k.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(shift_template, attrs) do
    shift_template
    |> cast(attrs, [
      :label,
      :subject,
      :description,
      :location,
      :timezone,
      :start_time,
      :length_hours,
      :length_minutes,
      :user_id
    ])
    |> validate_required([
      :subject,
      :timezone,
      :start_time,
      :length_hours
    ])
    |> validate_number(:length_hours, greater_than_or_equal_to: 0, less_than_or_equal_to: 24)
    |> validate_number(:length_minutes, greater_than_or_equal_to: 0, less_than: 60)
    |> validate_inclusion(:timezone, Tzdata.zone_list())
  end
end
