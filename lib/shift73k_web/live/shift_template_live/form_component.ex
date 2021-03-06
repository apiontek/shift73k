defmodule Shift73kWeb.ShiftTemplateLive.FormComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.ShiftTemplates

  @impl true
  def update(%{shift_template: shift_template} = assigns, socket) do
    changeset = ShiftTemplates.change_shift_template(shift_template)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"shift_template" => shift_template_params}, socket) do
    changeset =
      socket.assigns.shift_template
      |> ShiftTemplates.change_shift_template(shift_template_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"shift_template" => shift_template_params}, socket) do
    save_shift_template(socket, socket.assigns.action, shift_template_params)
  end

  defp save_shift_template(socket, :edit, shift_template_params) do
    case ShiftTemplates.update_shift_template(socket.assigns.shift_template, shift_template_params) do
      {:ok, _shift_template} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shift template updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_shift_template(socket, :new, shift_template_params) do
    case ShiftTemplates.create_shift_template(shift_template_params) do
      {:ok, _shift_template} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shift template created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
