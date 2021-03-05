defmodule Bones73kWeb.Roles do
  @moduledoc """
  Defines roles related functions.
  """

  alias Bones73k.Accounts.User
  alias Bones73k.Properties.Property

  @type entity :: struct()
  @type action :: :new | :index | :edit | :show | :delete | :edit_role
  @spec can?(%User{}, entity(), action()) :: boolean()

  def can?(user, entity, action)

  # Properties / Property
  def can?(%User{role: :admin}, %Property{}, _any), do: true
  def can?(%User{}, %Property{}, :index), do: true
  def can?(%User{}, %Property{}, :new), do: true
  def can?(%User{}, %Property{}, :show), do: true
  def can?(%User{id: id}, %Property{user_id: id}, :edit), do: true
  def can?(%User{id: id}, %Property{user_id: id}, :delete), do: true

  # Accounts / User
  def can?(%User{role: :admin}, %User{}, _any), do: true
  def can?(%User{role: :manager}, %User{}, :index), do: true
  def can?(%User{role: :manager}, %User{}, :new), do: true
  def can?(%User{role: :manager}, %User{}, :edit), do: true
  def can?(%User{role: :manager}, %User{}, :show), do: true

  # Final response
  def can?(_, _, _), do: false
end
