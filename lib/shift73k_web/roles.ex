defmodule Shift73kWeb.Roles do
  @moduledoc """
  Defines roles related functions.
  """

  alias Shift73k.Accounts.User
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @type entity :: struct()
  @type action :: :new | :index | :edit | :show | :delete | :edit_role
  @spec can?(%User{}, entity(), action()) :: boolean()

  def can?(user, entity, action)

  # Shifts.Templates / ShiftTemplate
  def can?(%User{role: :admin}, %ShiftTemplate{}, _any), do: true
  def can?(%User{}, %ShiftTemplate{}, :index), do: true
  def can?(%User{}, %ShiftTemplate{}, :new), do: true
  # def can?(%User{}, %ShiftTemplate{}, :show), do: true
  def can?(%User{id: id}, %ShiftTemplate{user_id: id}, :edit), do: true
  def can?(%User{id: id}, %ShiftTemplate{user_id: id}, :clone), do: true
  def can?(%User{id: id}, %ShiftTemplate{user_id: id}, :delete), do: true

  # Accounts / User
  def can?(%User{role: :admin}, %User{}, _any), do: true
  def can?(%User{role: :manager}, %User{}, :index), do: true
  def can?(%User{role: :manager}, %User{}, :new), do: true
  def can?(%User{role: :manager}, %User{}, :edit), do: true
  # def can?(%User{role: :manager}, %User{}, :show), do: true

  # Final response
  def can?(_, _, _), do: false
end
