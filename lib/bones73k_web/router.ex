defmodule Bones73kWeb.Router do
  use Bones73kWeb, :router
  import Bones73kWeb.UserAuth
  alias Bones73kWeb.EnsureRolePlug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {Bones73kWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :user do
    plug(EnsureRolePlug, [:admin, :manager, :user])
  end

  pipeline :manager do
    plug(EnsureRolePlug, [:admin, :manager])
  end

  pipeline :admin do
    plug(EnsureRolePlug, :admin)
  end

  scope "/", Bones73kWeb do
    pipe_through [:browser]

    live "/", PageLive, :index
    get "/other", OtherController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Bones73kWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: Bones73kWeb.Telemetry)
    end
  end

  scope "/", Bones73kWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
  end

  scope "/", Bones73kWeb do
    pipe_through([:browser, :require_authenticated_user])

    # # liveview user settings
    # live "/users/settings", UserLive.Settings, :edit

    # original user routes from phx.gen.auth
    # TODO:
    get("/users/settings", UserSettingsController, :edit)
    put("/users/settings/update_password", UserSettingsController, :update_password)
    put("/users/settings/update_email", UserSettingsController, :update_email)
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", Bones73kWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    # TODO: understanding/testing force_logout?
    get("/users/force_logout", UserSessionController, :force_logout)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)
  end

  scope "/", Bones73kWeb do
    pipe_through([:browser, :require_authenticated_user, :user])

    live("/user_dashboard", UserDashboardLive, :index)

    live("/properties", PropertyLive.Index, :index)
    live("/properties/new", PropertyLive.Index, :new)
    live("/properties/:id/edit", PropertyLive.Index, :edit)
    live("/properties/:id", PropertyLive.Show, :show)
    live("/properties/:id/show/edit", PropertyLive.Show, :edit)
  end

  scope "/", Bones73kWeb do
    pipe_through([:browser, :require_authenticated_user, :admin])

    live("/admin_dashboard", AdminDashboardLive, :index)
  end
end
