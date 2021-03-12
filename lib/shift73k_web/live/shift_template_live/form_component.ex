defmodule Shift73kWeb.ShiftTemplateLive.FormComponent do
  use Shift73kWeb, :live_component

  import Shift73kWeb.ShiftTemplateLive.Index, only: [format_shift_length: 1]

  alias Shift73k.Shifts.Templates
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @impl true
  def update(%{shift_template: shift_template} = assigns, socket) do
    changeset = Templates.change_shift_template(shift_template)

    socket
    |> assign(assigns)
    |> assign(:changeset, changeset)
    |> assign_shift_length(shift_template)
    |> live_okreply()
  end

  defp assign_shift_length(socket, shift_template) do
    assign(socket, :shift_length, format_shift_length(shift_template))
  end

  defp prep_template_params(params, current_user) do
    params
    |> Map.put("time_start", Time.from_iso8601!("T#{params["time_start"]}:00"))
    |> Map.put("time_end", Time.from_iso8601!("T#{params["time_end"]}:00"))
    |> Map.put("user_id", current_user.id)
  end

  @impl true
  def handle_event("validate", %{"shift_template" => params}, socket) do
    params = prep_template_params(params, socket.assigns.current_user)

    changeset =
      socket.assigns.shift_template
      |> Templates.change_shift_template(params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:changeset, changeset)
    |> assign_shift_length(%ShiftTemplate{
      time_end: params["time_end"],
      time_start: params["time_start"]
    })
    |> live_noreply()
  end

  def handle_event("save", %{"shift_template" => params}, socket) do
    save_shift_template(
      socket,
      socket.assigns.action,
      prep_template_params(params, socket.assigns.current_user)
    )
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, push_event(socket, "modal-please-hide", %{})}
  end

  defp save_shift_template(socket, :new, params) do
    case Templates.create_shift_template(params) do
      {:ok, _shift_template} ->
        flash = {:info, "Shift template created successfully"}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_shift_template(socket, :clone, params) do
    save_shift_template(socket, :new, params)
  end

  defp save_shift_template(socket, :edit, params) do
    case Templates.update_shift_template(socket.assigns.shift_template, params) do
      {:ok, _shift_template} ->
        flash = {:info, "Shift template updated successfully"}
        send(self(), {:put_flash_message, flash})

        socket
        |> push_event("modal-please-hide", %{})
        |> live_noreply()

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end
end
