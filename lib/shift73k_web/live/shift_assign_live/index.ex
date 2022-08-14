defmodule Shift73kWeb.ShiftAssignLive.Index do
  use Shift73kWeb, :live_view
  import Shift73k, only: [app_time_zone: 0]

  alias Shift73k.Repo
  alias Shift73k.Shifts
  alias Shift73k.Shifts.Templates
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @custom_shift %ShiftTemplate{subject: "Custom shift", id: "custom-shift"}
  @custom_shift_opt {@custom_shift.subject, @custom_shift.id}

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> assign(:page_title, "Schedule Shifts")
    |> assign(:custom_shift, @custom_shift)
    |> assign(:show_template_btn_active, false)
    |> assign(:show_template_details, false)
    |> assign(:selected_days, [])
    |> assign(:delete_days_shifts, nil)
    |> live_okreply()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> init_shift_templates()
    |> init_shift_template()
    |> show_details_if_custom()
    |> assign_shift_length()
    |> assign_shift_template_changeset()
    |> assign_modal_close_handlers()
    |> init_today(Date.utc_today())
    |> init_day_names()
    |> update_calendar()
    |> live_noreply()
  end

  defp assign_modal_close_handlers(socket) do
    to = Routes.shift_assign_index_path(socket, :index)
    assign(socket, modal_return_to: to, modal_close_action: :return)
  end

  defp get_shift_template("custom-shift"), do: @custom_shift
  defp get_shift_template(template_id), do: Templates.get_shift_template(template_id)

  defp assign_shift_length(%{assigns: %{shift_template: shift}} = socket) do
    assign(socket, :shift_length, format_shift_length(shift))
  end

  defp assign_known_shifts(%{assigns: %{current_user: user}} = socket) do
    date_range = socket.assigns.date_range
    known_shifts = Shifts.list_shifts_by_user_in_date_range(user.id, date_range)
    assign(socket, :known_shifts, known_shifts)
  end

  defp init_today(socket, today) do
    assign(socket, current_date: today, cursor_date: cursor_date(today))
  end

  defp cursor_date(%Date{} = date) do
    date |> Date.beginning_of_month() |> Date.add(4)
  end

  defp assign_shift_template_changeset(%{assigns: %{shift_template: shift}} = socket) do
    cs = Templates.change_shift_template(shift)
    assign(socket, :shift_template_changeset, cs)
  end

  defp init_shift_template(socket) do
    first_list_id = socket.assigns.shift_templates |> hd() |> elem(1)
    fave_id = socket.assigns.current_user.fave_shift_template_id
    assign_shift_template(socket, fave_id || first_list_id)
  end

  defp assign_shift_template(socket, template_id) do
    assign(socket, :shift_template, get_shift_template(template_id))
  end

  defp init_shift_templates(%{assigns: %{current_user: user}} = socket) do
    shift_templates =
      Templates.list_shift_templates_by_user(user.id)
      |> Stream.map(fn t -> shift_template_option(t, user.fave_shift_template_id) end)
      |> Enum.concat([@custom_shift_opt])

    assign(socket, :shift_templates, shift_templates)
  end

  defp shift_template_option(template, fave_id) do
    label =
      template.subject <>
        " (" <>
        format_shift_time(template.time_start) <>
        "—" <>
        format_shift_time(template.time_end) <> ")"

    label =
      case fave_id == template.id do
        true -> label <> " ★"
        false -> label
      end

    {label, template.id}
  end

  defp init_day_names(%{assigns: %{current_user: user, current_date: today}} = socket) do
    week_start = Date.beginning_of_week(today, user.week_start_at)

    day_names =
      week_start
      |> Date.range(Date.add(week_start, 6))
      |> Enum.map(&Calendar.strftime(&1, "%a"))

    assign(socket, :day_names, day_names)
  end

  defp date_range(cursor_date, week_start_at) do
    last =
      cursor_date
      |> Date.end_of_month()
      |> Date.end_of_week(week_start_at)

    cursor_date
    |> Date.beginning_of_month()
    |> Date.beginning_of_week(week_start_at)
    |> Date.range(last)
  end

  defp assign_date_range(%{assigns: %{current_user: user}} = socket) do
    date_range = date_range(socket.assigns.cursor_date, user.week_start_at)
    assign(socket, :date_range, date_range)
  end

  defp assign_week_rows(%{assigns: %{date_range: date_range}} = socket) do
    assign(socket, :week_rows, Enum.chunk_every(date_range, 7))
  end

  def day_color(day, current_date, cursor_date, selected_days) do
    cond do
      Enum.member?(selected_days, Date.to_string(day)) ->
        cond do
          Date.compare(day, current_date) == :eq -> "bg-triangle-info text-white"
          day.month != cursor_date.month -> "bg-triangle-light text-gray"
          true -> "bg-triangle-white"
        end

      Date.compare(day, current_date) == :eq ->
        "bg-info text-white"

      day.month != cursor_date.month ->
        "bg-light text-gray"

      true ->
        ""
    end
  end

  defp prep_template_params(params, current_user) do
    params
    |> Map.put("time_start", Time.from_iso8601!("T#{params["time_start"]}:00"))
    |> Map.put("time_end", Time.from_iso8601!("T#{params["time_end"]}:00"))
    |> Map.put("user_id", current_user.id)
  end

  defp show_details_if_custom(socket) do
    if socket.assigns.shift_template.id != @custom_shift.id ||
         socket.assigns.show_template_details do
      socket
    else
      socket
      |> assign(:show_template_btn_active, true)
      |> push_event("toggle-template-details", %{targetId: "#templateDetailsCol"})
    end
  end

  defp update_calendar(socket) do
    socket
    |> assign_date_range()
    |> assign_week_rows()
    |> assign_known_shifts()
  end

  defp new_nav_cursor("now", _cursor_date), do: Date.utc_today()

  defp new_nav_cursor(nav, cursor_date) do
    cursor_date
    |> Date.add((nav == "prev" && -30) || 30)
    |> cursor_date()
  end

  @impl true
  def handle_event("validate-shift-template", %{"shift_template" => params}, socket) do
    params = prep_template_params(params, socket.assigns.current_user)
    shift_template = socket.assigns.shift_template

    cs =
      shift_template
      |> Templates.change_shift_template(params)
      |> Map.put(:action, :validate)

    socket
    |> assign(:shift_template_changeset, cs)
    |> assign(:shift_template, Map.merge(shift_template, cs.changes))
    |> assign_shift_length()
    |> live_noreply()
  end

  @impl true
  def handle_event(
        "change-selected-template",
        %{"template_select" => %{"template" => template_id}},
        socket
      ) do
    socket
    |> assign_shift_template(template_id)
    |> show_details_if_custom()
    |> assign_shift_length()
    |> assign_shift_template_changeset()
    |> live_noreply()
  end

  @impl true
  def handle_event("month-nav", %{"month" => nav}, socket) do
    new_cursor = new_nav_cursor(nav, socket.assigns.cursor_date)

    socket
    |> assign(:cursor_date, new_cursor)
    |> update_calendar()
    |> live_noreply()
  end

  @impl true
  def handle_event("toggle-template-details", %{"target_id" => target_id}, socket) do
    socket
    |> assign(:show_template_btn_active, !socket.assigns.show_template_btn_active)
    |> push_event("toggle-template-details", %{targetId: target_id})
    |> live_noreply()
  end

  @impl true
  def handle_event("collapse-shown", %{"target_id" => _target_id}, socket) do
    {:noreply, assign(socket, :show_template_details, true)}
  end

  @impl true
  def handle_event("collapse-hidden", %{"target_id" => _target_id}, socket) do
    {:noreply, assign(socket, :show_template_details, false)}
  end

  @impl true
  def handle_event("select-day", %{"day" => day}, socket) do
    selected_days = update_selected_days(socket.assigns.selected_days, day)
    {:noreply, assign(socket, :selected_days, selected_days)}
  end

  @impl true
  def handle_event("delete-days-shifts", _params, socket) do
    socket
    |> assign(:modal_close_action, :delete_days_shifts)
    |> assign(:delete_days_shifts, socket.assigns.selected_days)
    |> live_noreply()
  end

  @impl true
  def handle_event("clear-days", _params, socket) do
    {:noreply, assign(socket, :selected_days, [])}
  end

  @impl true
  def handle_event("save-days", _params, socket) do
    # 1. collect attrs from loaded shift template
    shift_data = ShiftTemplate.attrs(socket.assigns.shift_template)

    # 2. fashion list of shift attrs and insert
    socket.assigns.selected_days
    |> Stream.map(&Date.from_iso8601!/1)
    |> Stream.map(&Map.put(shift_data, :date, &1))
    |> Enum.map(&Repo.timestamp/1)
    |> Shifts.create_multiple()
    |> handle_create_multiple_result(socket)
    |> assign(:selected_days, [])
    |> assign_known_shifts()
    |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end

  @impl true
  def handle_info({:clear_selected_days, _}, socket) do
    socket |> assign(:selected_days, []) |> live_noreply()
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_close_action: :return}} = socket) do
    socket
    |> copy_flash()
    |> push_patch(to: socket.assigns.modal_return_to)
    |> live_noreply()
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_close_action: assign_key}} = socket) do
    socket
    |> assign(assign_key, nil)
    |> assign_modal_close_handlers()
    |> assign_known_shifts()
    |> live_noreply()
  end

  defp handle_create_multiple_result(result, socket) do
    day_count = length(socket.assigns.selected_days)

    {status, msg} =
      case result do
        {:error, errmsg} ->
          {:error, "Ope, problem error inserting shifts, page the dev! Message: #{errmsg}"}

        {n, _} ->
          s = (n > 1 && "s") || ""

          if n == day_count do
            {:success, "Successfully assigned shift to #{n} day#{s}"}
          else
            {:warning, "Some error, only #{n} day#{s} inserted but #{day_count} were selected"}
          end
      end

    put_flash(socket, status, msg)
  end

  def shifts_to_show(day_shifts) do
    if length(day_shifts) == 1 || length(day_shifts) > 2,
      do: Enum.take(day_shifts, 1),
      else: day_shifts
  end

  defp update_selected_days(selected_days, day) do
    case Enum.member?(selected_days, day) do
      false -> [day | selected_days]
      true -> Enum.reject(selected_days, fn d -> d == day end)
    end
  end
end
