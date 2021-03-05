defmodule Bones73kWeb.UserManagementLive.Index do
  use Bones73kWeb, :live_view

  import Ecto.Query
  import Bones73kWeb.Pagination
  import Bones73k.Util.Dt

  alias Bones73k.Repo
  alias Bones73k.Accounts
  alias Bones73k.Accounts.User
  alias Bones73kWeb.Roles

  @impl true
  def mount(_params, session, socket) do
    socket
    |> assign_defaults(session)
    |> live_okreply()
  end

  @impl true
  def handle_params(params, _url, socket) do
    current_user = socket.assigns.current_user
    live_action = socket.assigns.live_action
    user = user_from_params(params)

    if Roles.can?(current_user, user, live_action) do
      socket
      |> assign(:query, query_map(params))
      |> assign_modal_return_to()
      |> page_query()
      |> apply_action(socket.assigns.live_action, params)
      |> live_noreply()
    else
      socket
      |> put_flash(:error, "Unauthorised")
      |> redirect(to: "/")
      |> live_noreply()
    end
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Users")
    |> assign(:user, nil)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New User")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit User")
    |> assign(:user, Accounts.get_user!(id))
  end

  def assign_modal_return_to(%{assigns: %{query: query}} = socket) do
    to = Routes.user_management_index_path(socket, :index, Enum.into(query, []))
    assign(socket, :modal_return_to, to)
  end

  defp user_from_params(params)

  defp user_from_params(%{"id" => id}),
    do: Accounts.get_user!(id)

  defp user_from_params(_params), do: %User{}

  def query_map(params) do
    %{
      filter: params["filter"] || "",
      sort_by: (params["sort_by"] in ~w(email inserted_at role) && params["sort_by"]) || "email",
      sort_order: (params["sort_order"] == "desc" && "desc") || "asc",
      page_number: String.to_integer(params["page_number"] || "1"),
      page_size: String.to_integer(params["page_size"] || "10")
    }
  end

  defp page_query(%{assigns: %{query: query}} = socket) do
    result_page =
      from(u in User)
      |> or_where([u], ilike(u.email, ^"%#{query.filter}%"))
      # |> or_where([u], ilike(u.singer_name, ^"%#{query.filter}%"))
      |> order_by([u], [
        {^String.to_existing_atom(query.sort_order), ^String.to_existing_atom(query.sort_by)}
      ])
      |> Repo.paginate(page: query.page_number, page_size: query.page_size)

    socket
    |> assign(:page, result_page)
    |> assign(:table_loading, false)
  end

  @impl true
  def handle_event("delete", %{"id" => id, "email" => email}, socket) do
    id
    |> Accounts.get_user()
    |> Accounts.delete_user()
    |> case do
      {:ok, _} ->
        socket
        |> put_flash(:success, "User deleted successfully: \"#{email}\"")
        |> assign(:table_loading, true)
        |> page_query()
        |> live_noreply()

      {:error, _} ->
        socket
        |> put_flash(
          :error,
          "Something went wrong attempting to delete user \"#{email}\". Possibly already deleted? Reloading list..."
        )
        |> assign(:table_loading, true)
        |> page_query()
        |> live_noreply()
    end
  end

  @impl true
  def handle_event("filter-change", params, socket) do
    send(self(), {:query_update, Map.put(params, "page_number", "1")})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event("filter-clear", _params, socket) do
    send(self(), {:query_update, %{"filter" => "", "page_number" => "1"}})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event(
        "sort-change",
        %{"sort_by" => column} = params,
        %{assigns: %{query: query}} = socket
      ) do
    (column == query.sort_by &&
       send(
         self(),
         {:query_update, %{"sort_order" => (query.sort_order == "asc" && "desc") || "asc"}}
       )) ||
      send(self(), {:query_update, Map.put(params, "sort_order", "asc")})

    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event("sort-by-change", %{"sort" => params}, socket) do
    send(self(), {:query_update, params})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event("sort-order-change", _params, socket) do
    new_sort_order = (socket.assigns.query.sort_order == "asc" && "desc") || "asc"
    send(self(), {:query_update, %{"sort_order" => new_sort_order}})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event("page-change", params, socket) do
    send(self(), {:query_update, params})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_event("page-size-change", params, socket) do
    send(self(), {:query_update, Map.put(params, "page_number", "1")})
    {:noreply, assign(socket, :table_loading, true)}
  end

  @impl true
  def handle_info({:query_update, params}, %{assigns: %{query: q}} = socket) do
    {:noreply,
     push_patch(socket,
       to: Routes.user_management_index_path(socket, :index, get_new_params(params, q)),
       replace: true
     )}
  end

  @impl true
  def handle_info({:close_modal, _}, %{assigns: %{modal_return_to: to}} = socket) do
    socket |> copy_flash() |> push_patch(to: to) |> live_noreply()
  end

  @impl true
  def handle_info({:put_flash_message, {flash_type, msg}}, socket) do
    socket |> put_flash(flash_type, msg) |> live_noreply()
  end

  defp get_new_params(params, query) do
    [
      {:filter, Map.get(params, "filter") || query.filter},
      {:sort_by, Map.get(params, "sort_by") || query.sort_by},
      {:sort_order, Map.get(params, "sort_order") || query.sort_order},
      {:page_number, Map.get(params, "page_number") || query.page_number},
      {:page_size, Map.get(params, "page_size") || query.page_size}
    ]
  end

  def dt_out(ndt), do: format_ndt(ndt, "{YYYY} {Mshort} {0D}, {h12}:{0m} {am}")
end