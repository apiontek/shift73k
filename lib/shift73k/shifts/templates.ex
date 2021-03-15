defmodule Shift73k.Shifts.Templates do
  @moduledoc """
  The Shifts.Templates context.
  """

  import Ecto.Query, warn: false
  alias Shift73k.Repo

  alias Shift73k.Shifts.Templates.ShiftTemplate

  @doc """
  Returns the list of shift_templates.

  ## Examples

      iex> list_shift_templates()
      [%ShiftTemplate{}, ...]

  """
  def list_shift_templates do
    Repo.all(ShiftTemplate)
  end

  def list_shift_templates_by_user_id(user_id) do
    q = from s in ShiftTemplate, where: s.user_id == ^user_id, order_by: s.subject
    Repo.all(q)
  end

  @doc """
  Gets a single shift_template.

  Raises `Ecto.NoResultsError` if the Shift template does not exist.

  ## Examples

      iex> get_shift_template!(123)
      %ShiftTemplate{}

      iex> get_shift_template!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shift_template!(nil), do: nil
  def get_shift_template!(id), do: Repo.get!(ShiftTemplate, id)

  def get_shift_template(nil), do: nil
  def get_shift_template(id), do: Repo.get(ShiftTemplate, id)

  @doc """
  Creates a shift_template.

  ## Examples

      iex> create_shift_template(%{field: value})
      {:ok, %ShiftTemplate{}}

      iex> create_shift_template(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shift_template(attrs \\ %{}) do
    %ShiftTemplate{}
    |> ShiftTemplate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shift_template.

  ## Examples

      iex> update_shift_template(shift_template, %{field: new_value})
      {:ok, %ShiftTemplate{}}

      iex> update_shift_template(shift_template, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shift_template(%ShiftTemplate{} = shift_template, attrs) do
    shift_template
    |> ShiftTemplate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shift_template.

  ## Examples

      iex> delete_shift_template(shift_template)
      {:ok, %ShiftTemplate{}}

      iex> delete_shift_template(shift_template)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shift_template(%ShiftTemplate{} = shift_template) do
    Repo.delete(shift_template)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shift_template changes.

  ## Examples

      iex> change_shift_template(shift_template)
      %Ecto.Changeset{data: %ShiftTemplate{}}

  """
  def change_shift_template(%ShiftTemplate{} = shift_template, attrs \\ %{}) do
    ShiftTemplate.changeset(shift_template, attrs)
  end
end
