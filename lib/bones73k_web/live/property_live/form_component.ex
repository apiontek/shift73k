defmodule Bones73kWeb.PropertyLive.FormComponent do
  use Bones73kWeb, :live_component

  alias Bones73k.Properties

  @impl true
  def update(%{property: property} = assigns, socket) do
    socket
    |> assign(assigns)
    |> assign(:changeset, Properties.change_property(property))
    |> live_okreply()
  end

  @impl true
  def handle_event("validate", %{"property" => property_params}, socket) do
    changeset =
      socket.assigns.property
      |> Properties.change_property(property_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"property" => property_params}, socket) do
    save_property(socket, socket.assigns.action, property_params)
  end

  defp save_property(socket, :edit, property_params) do
    case Properties.update_property(socket.assigns.property, property_params) do
      {:ok, _property} ->
        socket
        |> put_flash(:info, "Property updated successfully")
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_property(socket, :new, property_params) do
    current_user = socket.assigns.current_user
    property_params = Map.put(property_params, "user_id", current_user.id)

    case Properties.create_property(property_params) do
      {:ok, _property} ->
        socket
        |> put_flash(:info, "Property created successfully")
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
