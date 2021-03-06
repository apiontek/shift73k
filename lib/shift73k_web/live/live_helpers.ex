defmodule Shift73kWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User
  alias Shift73kWeb.UserAuth

  @doc """
  Performs the {:noreply, socket} for a given socket.
  This helps make the noreply pipeable
  """
  def live_noreply(socket), do: {:noreply, socket}

  @doc """
  Performs the {:ok, socket} for a given socket.
  This helps make the ok reply pipeable
  """
  def live_okreply(socket), do: {:ok, socket}

  @doc """
  Renders a component inside the `Shift73kWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, Shift73kWeb.PropertyLive.FormComponent,
        id: @property.id || :new,
        action: @live_action,
        property: @property,
        return_to: Routes.property_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    modal_opts = [id: :modal, component: component, opts: opts]
    # dirty little workaround for elixir complaining about socket being unused
    _socket = socket
    live_component(socket, Shift73kWeb.ModalComponent, modal_opts)
  end

  @doc """
  Loads default assigns for liveviews
  """
  def assign_defaults(socket, session) do
    Shift73kWeb.Endpoint.subscribe(UserAuth.pubsub_topic())
    assign_current_user(socket, session)
  end

  # For liveviews, ensures current_user is in socket assigns.
  def assign_current_user(socket, session) do
    with user_token when not is_nil(user_token) <- session["user_token"],
         %User{} = user <- Accounts.get_user_by_session_token(user_token) do
      assign(socket, :current_user, user)
    else
      _ -> socket
    end
  end

  @doc """
  Copies current flash into new put_flash invocations.
  To be used before a push_patch.
  """
  def copy_flash(%{assigns: %{flash: flash}} = socket) do
    Enum.reduce(flash, socket, fn {k, v}, acc ->
      put_flash(acc, String.to_existing_atom(k), v)
    end)
  end
end
