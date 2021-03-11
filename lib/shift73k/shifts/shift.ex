defmodule Shift73k.Shifts.Shift do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "shifts" do
    field :subject, :string
    field :description, :string
    field :location, :string
    field :date, :date
    field :time_zone, :string
    field :time_start, :time
    field :time_end, :time

    belongs_to(:user, Shift73k.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(shift, attrs) do
    shift
    |> cast(attrs, [
      :subject,
      :location,
      :description,
      :date,
      :time_zone,
      :time_start,
      :time_end,
      :user_id
    ])

    # |> validate_required([
    #   :subject,
    #   :date,
    #   :time_zone,
    #   :time_start,
    #   :time_end,
    #   :user_id
    # ])
  end
end
