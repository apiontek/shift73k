defmodule Shift73k.Shifts do
  @moduledoc """
  The Shifts context.
  """

  import Ecto.Query, warn: false
  alias Shift73k.Repo

  alias Shift73k.Shifts.Shift

  @doc """
  Returns the list of shifts.

  ## Examples

      iex> list_shifts()
      [%Shift{}, ...]

  """
  def list_shifts do
    Repo.all(Shift)
  end

  def query_shifts_by_user(user_id) do
    from(s in Shift)
    |> where([s], s.user_id == ^user_id)
  end

  def list_shifts_by_user(user_id) do
    user_id
    |> query_shifts_by_user()
    |> Repo.all()
  end

  def list_shifts_by_user_in_date_range(user_id, %Date.Range{} = date_range) do
    user_id
    |> query_shifts_by_user()
    |> where([s], s.date >= ^date_range.first)
    |> where([s], s.date <= ^date_range.last)
    |> order_by([s], [s.date, s.time_start])
    |> Repo.all()
  end

  defp query_shifts_by_user_from_list_of_dates(user_id, date_list) do
    user_id
    |> query_shifts_by_user()
    |> where([s], s.date in ^date_list)
  end

  def list_shifts_by_user_from_list_of_dates(user_id, date_list) do
    user_id
    |> query_shifts_by_user_from_list_of_dates(date_list)
    |> Repo.all()
  end

  def query_user_shift_dates(user_id) do
    query_shifts_by_user(user_id)
    |> select([s], s.date)
  end

  def get_min_user_shift_date(user_id) do
    query_user_shift_dates(user_id)
    |> order_by([s], asc: s.date)
    |> limit([s], 1)
    |> Repo.one()
  end

  def get_max_user_shift_date(user_id) do
    query_user_shift_dates(user_id)
    |> order_by([s], desc: s.date)
    |> limit([s], 1)
    |> Repo.one()
  end

  @doc """
  Gets a single shift.

  Raises `Ecto.NoResultsError` if the Shift does not exist.

  ## Examples

      iex> get_shift!(123)
      %Shift{}

      iex> get_shift!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift!(nil), do: nil
  def get_shift!(id), do: Repo.get!(Shift, id)

  def get_shift(nil), do: nil
  def get_shift(id), do: Repo.get(Shift, id)

  @doc """
  Creates a shift.

  ## Examples

      iex> create_shift(%{field: value})
      {:ok, %Shift{}}

      iex> create_shift(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift(attrs \\ %{}) do
    %Shift{}
    |> Shift.changeset(attrs)
    |> Repo.insert()
  end

  def create_multiple(shift_attrs) when is_list(shift_attrs) do
    try do
      Repo.insert_all(Shift, shift_attrs)
    rescue
      e in Postgrex.Error -> {:error, e.message}
    end
  end

  @doc """
  Updates a shift.

  ## Examples

      iex> update_shift(shift, %{field: new_value})
      {:ok, %Shift{}}

      iex> update_shift(shift, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift(%Shift{} = shift, attrs) do
    shift
    |> Shift.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift.

  ## Examples

      iex> delete_shift(shift)
      {:ok, %Shift{}}

      iex> delete_shift(shift)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift(%Shift{} = shift) do
    Repo.delete(shift)
  end

  def delete_shifts_by_user_from_list_of_dates(user_id, date_list) do
    query_shifts_by_user_from_list_of_dates(user_id, date_list)
    |> Repo.delete_all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift changes.

  ## Examples

      iex> change_shift(shift)
      %Ecto.Changeset{data: %Shift{}}

  """
  def change_shift(%Shift{} = shift, attrs \\ %{}) do
    Shift.changeset(shift, attrs)
  end

  ###
  # UTILS
  def shift_length(%{time_end: time_end, time_start: time_start}) do
    time_end
    |> Time.diff(time_start)
    |> Integer.floor_div(60)
    |> shift_length()
  end

  def shift_length(len_min) when is_integer(len_min) and len_min >= 0, do: len_min
  def shift_length(len_min) when is_integer(len_min) and len_min < 0, do: 1440 + len_min

  def shift_length(time_end, time_start) do
    shift_length(%{time_end: time_end, time_start: time_start})
  end
end
