defmodule Shift73k.Shifts.Templates.ShiftTemplate do
  use Timex
  use Ecto.Schema
  import Ecto.Changeset

  alias Shift73k.Shifts.Templates.ShiftTemplate

  @app_vars Application.get_env(:shift73k, :app_global_vars, time_zone: "America/New_York")
  @time_zone @app_vars[:time_zone]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shift_templates" do
    field :subject, :string
    field :description, :string
    field :location, :string
    field :time_zone, :string, default: @time_zone
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
      shift_length = shift_length(time_end, time_start_from_attrs(attrs))

      cond do
        shift_length == 0 ->
          [time_end: "end time cannot equal start time"]

        shift_length >= 16 * 60 ->
          [time_end: "you don't want to work 16 or more hours!"]

        true ->
          []
      end
    end)
    |> validate_inclusion(:time_zone, Timex.timezones(),
      message: "must be a valid IANA tz database time zone"
    )
  end

  defp time_start_from_attrs(%{"time_start" => time_start}), do: time_start
  defp time_start_from_attrs(%{time_start: time_start}), do: time_start
  defp time_start_from_attrs(_), do: nil

  def shift_length(%ShiftTemplate{time_end: time_end, time_start: time_start}) do
    time_end
    |> Timex.diff(time_start, :minute)
    |> shift_length()
  end

  def shift_length(len_min) when is_integer(len_min) and len_min >= 0, do: len_min
  def shift_length(len_min) when is_integer(len_min) and len_min < 0, do: 1440 + len_min

  def shift_length(time_end, time_start),
    do: shift_length(%ShiftTemplate{time_end: time_end, time_start: time_start})

  def shift_length_h_m(%ShiftTemplate{time_end: _, time_start: _} = template) do
    shift_length_seconds = shift_length(template)
    h = shift_length_seconds |> Integer.floor_div(60)
    m = shift_length_seconds |> rem(60)
    {h, m}
  end
end
