defmodule Shift73kWeb.ShiftAssignLive.Index do
  use Shift73kWeb, :live_view
  use Timex

  alias Ecto.Multi
  alias Shift73k.Repo
  alias Shift73k.EctoEnums.WeekdayEnum
  alias Shift73k.Shifts
  alias Shift73k.Shifts.Shift
  alias Shift73k.Shifts.Templates
  alias Shift73k.Shifts.Templates.ShiftTemplate

  @custom_shift %ShiftTemplate{subject: "Custom shift", id: "custom-shift"}
  @custom_shift_opt {@custom_shift.subject, @custom_shift.id}

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> assign(:custom_shift, @custom_shift)
    |> assign(:show_template_btn_active, false)
    |> assign(:show_template_details, false)
    |> assign(:selected_days, [])
    |> assign(:delete_days_shifts, nil)
    |> live_okreply()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    user = socket.assigns.current_user

    socket
    |> init_shift_templates()
    |> init_shift_template()
    |> show_details_if_custom()
    |> assign_shift_length()
    |> assign_shift_template_changeset()
    |> assign_modal_close_handlers()
    |> assign(:day_names, day_names(user.week_start_at))
    |> init_today(Timex.today())
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
    assign(socket, current_date: today, cursor_date: today)
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
      Templates.list_shift_templates_by_user_id(user.id)
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

  defp rotate_week(week_start_at) do
    {a, b} = Enum.split_while(WeekdayEnum.__enum_map__(), fn {k, _v} -> k != week_start_at end)
    b ++ a
  end

  defp day_names(week_start_at) do
    week_start_at
    |> rotate_week()
    |> Keyword.values()
    |> Enum.map(&Timex.day_shortname/1)
  end

  defp date_range(cursor_date, week_start_at) do
    last =
      cursor_date
      |> Timex.end_of_month()
      |> Timex.end_of_week(week_start_at)

    cursor_date
    |> Timex.beginning_of_month()
    |> Timex.beginning_of_week(week_start_at)
    |> Date.range(last)
  end

  defp assign_date_range(%{assigns: %{current_user: user}} = socket) do
    date_range = date_range(socket.assigns.cursor_date, user.week_start_at)
    assign(socket, :date_range, date_range)
  end

  defp week_rows(%Date.Range{} = date_range) do
    Interval.new(from: date_range.first, until: date_range.last, right_open: false)
    |> Stream.map(&NaiveDateTime.to_date(&1))
    |> Enum.chunk_every(7)
  end

  defp assign_week_rows(%{assigns: %{date_range: date_range}} = socket) do
    assign(socket, :week_rows, week_rows(date_range))
  end

  def day_color(day, current_date, cursor_date, selected_days) do
    cond do
      Enum.member?(selected_days, Date.to_string(day)) ->
        cond do
          Timex.compare(day, current_date, :days) == 0 -> "bg-triangle-info text-white"
          day.month != cursor_date.month -> "bg-triangle-light text-gray"
          true -> "bg-triangle-white"
        end

      Timex.compare(day, current_date, :days) == 0 ->
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
  def handle_event("month-nav", %{"month" => direction}, socket) do
    new_cursor =
      cond do
        direction == "now" ->
          Timex.today()

        true ->
          months = (direction == "prev" && -1) || 1
          Timex.shift(socket.assigns.cursor_date, months: months)
      end

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
    selected_days =
      case Enum.member?(socket.assigns.selected_days, day) do
        false -> [day | socket.assigns.selected_days]
        true -> Enum.reject(socket.assigns.selected_days, fn d -> d == day end)
      end

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
    shift_data = shift_data_from_template(socket.assigns.shift_template)

    # 2. create list of shift attrs to insert
    to_insert =
      Enum.map(socket.assigns.selected_days, &shift_from_day_and_shift_data(&1, shift_data))

    # 3. insert the data
    {status, msg} = insert_shifts(to_insert, length(socket.assigns.selected_days))

    socket
    |> put_flash(status, msg)
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

  defp shift_data_from_template(shift_template) do
    shift_template
    |> Map.from_struct()
    |> Map.drop([:__meta__, :id, :inserted_at, :updated_at, :user, :is_fave_of_user])
  end

  defp shift_from_day_and_shift_data(day, shift_data) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    date_data = %{date: Date.from_iso8601!(day), inserted_at: now, updated_at: now}
    Map.merge(shift_data, date_data)
  end

  defp insert_shifts(to_insert, day_count) do
    Multi.new()
    |> Multi.insert_all(:insert_all, Shift, to_insert)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_all: {n, _}}} ->
        s = (n > 1 && "s") || ""

        if n == day_count do
          {:success, "Successfully assigned shift to #{n} day#{s}"}
        else
          {:warning, "Some error, only #{n} day#{s} inserted but #{day_count} were selected"}
        end

      _ ->
        {:error, "Ope, unknown error inserting shifts, page the dev"}
    end
  end

  def shifts_to_show(day_shifts) do
    if length(day_shifts) == 1 || length(day_shifts) > 2,
      do: Enum.take(day_shifts, 1),
      else: day_shifts
  end
end
