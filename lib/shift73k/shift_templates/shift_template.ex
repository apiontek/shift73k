defmodule Shift73k.ShiftTemplates.ShiftTemplate do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shift_templates" do
    field :label, :string
    field :subject, :string
    field :description, :string
    field :location, :string
    field :timezone, :string
    field :start_time, :time
    field :length_hours, :integer
    field :length_minutes, :integer

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
