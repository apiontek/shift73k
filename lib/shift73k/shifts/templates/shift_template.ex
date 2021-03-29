defmodule Shift73k.Shifts.Templates.ShiftTemplate do
  use Ecto.Schema
  import Ecto.Changeset
  import Shift73k, only: [app_time_zone: 0]

  alias Shift73k.Shifts
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shift_templates" do
    field :subject, :string
    field :description, :string
    field :location, :string
    field :time_zone, :string, default: app_time_zone()
    field :time_start, :time, default: ~T[09:00:00]
    field :time_end, :time, default: ~T[17:00:00]

    belongs_to(:user, Shift73k.Accounts.User)
    has_one(:is_fave_of_user, Shift73k.Accounts.User, foreign_key: :fave_shift_template_id)

    timestamps()
  end

  @doc false
  def changeset(shift_template, attrs) do
    shift_template
    |> cast(attrs, [
      :subject,
      :location,
      :description,
      :time_zone,
      :time_start,
      :time_end,
      :user_id
    ])
    |> validate_required([
      :subject,
      :time_zone,
      :time_start,
      :time_end,
      :user_id
    ])
    |> validate_length(:subject, count: :codepoints, max: 280)
    |> validate_length(:location, count: :codepoints, max: 280)
    |> validate_change(:time_end, fn :time_end, time_end ->
      shift_length = Shifts.shift_length(time_end, time_start_from_attrs(attrs))

      cond do
        shift_length == 0 ->
          [time_end: "end time cannot equal start time"]

        shift_length >= 16 * 60 ->
          [time_end: "you don't want to work 16 or more hours!"]

        true ->
          []
      end
    end)
    |> validate_inclusion(:time_zone, Tzdata.zone_list(),
      message: "must be a valid IANA tz database time zone"
    )
  end

  defp time_start_from_attrs(%{"time_start" => time_start}), do: time_start
  defp time_start_from_attrs(%{time_start: time_start}), do: time_start
  defp time_start_from_attrs(_), do: nil

  # Get shift attrs from shift template
  def attrs(%ShiftTemplate{} = shift_template) do
    shift_template
    |> Map.from_struct()
    |> Map.drop([:__meta__, :id, :inserted_at, :updated_at, :user, :is_fave_of_user])
  end
end
