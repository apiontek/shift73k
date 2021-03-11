defmodule Shift73kWeb.Router do
  use Shift73kWeb, :router
  import Shift73kWeb.UserAuth
  alias Shift73kWeb.EnsureRolePlug

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {Shift73kWeb.LayoutView, :root})
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

  scope "/", Shift73kWeb do
    pipe_through([:browser])

    live("/", PageLive, :index)
    get("/other", OtherController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", Shift73kWeb do
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
      live_dashboard("/dashboard", metrics: Shift73kWeb.Telemetry)
    end
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    get("/users/register", UserRegistrationController, :new)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :require_authenticated_user])

    # # liveview user settings
    live("/users/settings", UserLive.Settings, :edit)

    # original user routes from phx.gen.auth
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser])

    delete("/users/log_out", UserSessionController, :delete)
    get("/users/force_logout", UserSessionController, :force_logout)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :require_authenticated_user, :user])

    live "/templates", ShiftTemplateLive.Index, :index
    live "/templates/new", ShiftTemplateLive.Index, :new
    live "/templates/:id/edit", ShiftTemplateLive.Index, :edit
    live "/templates/:id/clone", ShiftTemplateLive.Index, :clone

    live "/shifts", ShiftLive.Index, :index
    live "/shifts/new", ShiftLive.Index, :new
    live "/shifts/:id/edit", ShiftLive.Index, :edit

    live "/shifts/:id", ShiftLive.Show, :show
    live "/shifts/:id/show/edit", ShiftLive.Show, :edit
  end

  # scope "/", Shift73kWeb do
  #   pipe_through([:browser, :require_authenticated_user, :admin])
  # end

  # Users Management
  scope "/users", Shift73kWeb do
    pipe_through([:browser, :require_authenticated_user, :manager, :require_email_confirmed])

    live("/", UserManagementLive.Index, :index)
    live("/new", UserManagementLive.Index, :new)
    live("/edit/:id", UserManagementLive.Index, :edit)
    # resources "/", UserManagementController, only: [:new, :create, :edit, :update]
  end
end
