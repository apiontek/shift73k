defmodule Shift73kWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use Shift73kWeb, :controller
      use Shift73kWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: Shift73kWeb

      import Plug.Conn
      import Shift73kWeb.Gettext
      alias Shift73kWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/shift73k_web/templates",
        namespace: Shift73kWeb,
        pattern: "**/*"

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {Shift73kWeb.LayoutView, "live.html"}

      unquote(view_helpers())
      import Shift73kWeb.LiveHelpers

      alias Shift73k.Accounts.User

      @impl true
      def handle_info(%{event: "logout_user", payload: %{user: %User{id: id}}}, socket) do
        case socket.assigns.current_user do
          %User{id: ^id} ->
            {:noreply, redirect(socket, to: Routes.user_session_path(socket, :force_logout))}

          _ ->
            {:noreply, socket}
        end
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      # Import General Custom Live Helpers
      import Shift73kWeb.LiveHelpers

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import Shift73kWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import Shift73kWeb.ErrorHelpers
      import Shift73kWeb.Gettext
      alias Shift73kWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
