defmodule Shift73k.ShiftTemplates.ShiftTemplate do
  use Ecto.Schema
  import Ecto.Changeset

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
      :time_end
    ])
    |> validate_length(:subject, count: :codepoints, max: 280)
    |> validate_length(:location, count: :codepoints, max: 280)
    |> validate_change(:time_end, fn :time_end, time_end ->
      shift_length = shift_length(get_time_start(attrs), time_end)

      cond do
        shift_length == 0 ->
          [time_end: "end time cannot equal start time"]

        shift_length >= 16 * 3600 ->
          [time_end: "you don't want to work 16 or more hours!"]

        true ->
          []
      end
    end)
    |> validate_inclusion(:time_zone, Tzdata.zone_list())
  end

  defp get_time_start(%{"time_start" => time_start}), do: time_start
  defp get_time_start(%{time_start: time_start}), do: time_start
  defp get_time_start(_), do: nil

  def shift_length(time_start, time_end) do
    cond do
      time_end > time_start ->
        Time.diff(time_end, time_start)

      time_start > time_end ->
        len1 = Time.diff(~T[23:59:59], time_start) + 1
        len2 = Time.diff(time_end, ~T[00:00:00])
        len1 + len2

      true ->
        0
    end
  end

  def shift_length_h_m_tuple(time_start, time_end) do
    shift_length_seconds = shift_length(time_start, time_end)
    h = shift_length_seconds |> Integer.floor_div(3600)
    m = shift_length_seconds |> rem(3600) |> Integer.floor_div(60)
    {h, m}
  end
end
