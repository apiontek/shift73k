defmodule Shift73kWeb.ShiftTemplateLive.FormComponent do
  use Shift73kWeb, :live_component

  alias Shift73k.Shifts.Templates
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @impl true
  def update(%{shift_template: shift_template} = assigns, socket) do
    changeset = Templates.change_shift_template(shift_template)

    socket
    |> assign(assigns)
    |> assign(:changeset, changeset)
    |> assign_shift_length(shift_template.time_start, shift_template.time_end)
    |> live_okreply()
  end

  defp assign_shift_length(socket, time_start, time_end) do
    shift_length = ShiftTemplate.shift_length_h_m_tuple(time_start, time_end)
    assign(socket, :shift_length, shift_length)
  end

  defp prep_shift_template_params(shift_template_params, current_user) do
    time_start = Time.from_iso8601!("T#{shift_template_params["time_start"]}:00")
    time_end = Time.from_iso8601!("T#{shift_template_params["time_end"]}:00")

    shift_template_params
    |> Map.put("time_start", time_start)
    |> Map.put("time_end", time_end)
    |> Map.put("user_id", current_user.id)
  end

  @impl true
  def handle_event("validate", %{"shift_template" => shift_template_params}, socket) do
    shift_template_params =
      prep_shift_template_params(shift_template_params, socket.assigns.current_user)

    changeset =
      socket.assigns.shift_template
      |> Templates.change_shift_template(shift_template_params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:changeset, changeset)
    |> assign_shift_length(
      shift_template_params["time_start"],
      shift_template_params["time_end"]
    )
    |> live_noreply()
  end

  def handle_event("save", %{"shift_template" => shift_template_params}, socket) do
    save_shift_template(
      socket,
      socket.assigns.action,
      prep_shift_template_params(shift_template_params, socket.assigns.current_user)
    )
  end

  @impl true
  def handle_event("cancel", _, socket) do
    {:noreply, push_event(socket, "modal-please-hide", %{})}
  end

  defp save_shift_template(socket, :new, shift_template_params) do
    case Templates.create_shift_template(shift_template_params) do
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

  defp save_shift_template(socket, :clone, shift_template_params) do
    save_shift_template(socket, :new, shift_template_params)
  end

  defp save_shift_template(socket, :edit, shift_template_params) do
    case Templates.update_shift_template(
           socket.assigns.shift_template,
           shift_template_params
         ) do
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
