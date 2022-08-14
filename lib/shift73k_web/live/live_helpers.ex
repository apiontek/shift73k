defmodule Shift73kWeb.LiveHelpers do
  import Phoenix.LiveView

  alias Shift73k.Accounts
  alias Shift73k.Accounts.User
  alias Shift73kWeb.UserAuth
  alias Shift73k.Shifts

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

  def format_shift_time(time) do
    time
    |> Calendar.strftime("%-I:%M%P")
    |> String.trim_trailing("m")
  end

  def format_shift_length(%{} = shift_or_template) do
    shift_or_template
    |> Shifts.shift_length()
    |> format_shift_length()
  end

  def format_shift_length(minutes) when is_integer(minutes) do
    h = Integer.floor_div(minutes, 60)
    m = rem(minutes, 60)

    cond do
      h > 0 && m > 0 -> "#{h}h #{m}m"
      h > 0 -> "#{h}h"
      m > 0 -> "#{m}m"
      true -> "0m"
    end
  end
end
