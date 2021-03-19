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

  def list_shifts_by_user_between_dates(user_id, start_date, end_date) do
    from(s in Shift)
    |> select([s], %{
      date: s.date,
      subject: s.subject,
      time_start: s.time_start,
      time_end: s.time_end
    })
    |> where([s], s.user_id == ^user_id and s.date >= ^start_date and s.date <= ^end_date)
    |> order_by([s], [s.date, s.time_start])
    |> Repo.all()
  end

  defp query_shifts_by_user_on_list_of_dates(user_id, date_list) do
    from(s in Shift)
    |> where([s], s.user_id == ^user_id and s.date in ^date_list)
  end

  def list_shifts_by_user_on_list_of_dates(user_id, date_list) do
    query_shifts_by_user_on_list_of_dates(user_id, date_list)
    |> Repo.all()
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
  def get_shift!(id), do: Repo.get!(Shift, id)

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

  def delete_shifts_by_user_on_list_of_dates(user_id, date_list) do
    query_shifts_by_user_on_list_of_dates(user_id, date_list)
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
end
