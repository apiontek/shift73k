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

  pipeline :user do
    plug(EnsureRolePlug, [:admin, :manager, :user])
  end

  pipeline :manager do
    plug(EnsureRolePlug, [:admin, :manager])
  end

  pipeline :admin do
    plug(EnsureRolePlug, :admin)
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser])

    get("/", Redirector, to: "/assign")
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :redirect_if_user_is_authenticated])

    # session routes, irrelevant if user is authenticated
    get("/users/register", UserRegistrationController, :new)
    get("/users/log_in", UserSessionController, :new)
    post("/users/log_in", UserSessionController, :create)
    get("/users/reset_password", UserResetPasswordController, :new)
    post("/users/reset_password", UserResetPasswordController, :create)
    get("/users/reset_password/:token", UserResetPasswordController, :edit)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :require_authenticated_user])

    # user settings (change email, password, calendar week start, etc)
    live("/users/settings", UserLive.Settings, :edit)

    # confirm email by token
    get("/users/settings/confirm_email/:token", UserSettingsController, :confirm_email)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser])

    # session paths
    delete("/users/log_out", UserSessionController, :delete)
    get("/users/force_logout", UserSessionController, :force_logout)
    get("/users/confirm", UserConfirmationController, :new)
    post("/users/confirm", UserConfirmationController, :create)
    get("/users/confirm/:token", UserConfirmationController, :confirm)

    # ics/ical route for user's shifts
    get("/ics/:slug", UserShiftsIcsController, :index)
  end

  scope "/", Shift73kWeb do
    pipe_through([:browser, :require_authenticated_user, :user])

    live "/templates", ShiftTemplateLive.Index, :index
    live "/templates/new", ShiftTemplateLive.Index, :new
    live "/templates/:id/edit", ShiftTemplateLive.Index, :edit
    live "/templates/:id/clone", ShiftTemplateLive.Index, :clone

    live "/assign", ShiftAssignLive.Index, :index

    live "/shifts", ShiftLive.Index, :index

    get "/csv", UserShiftsCsvController, :new
    post "/csv", UserShiftsCsvController, :export

    live "/import", ShiftImportLive.Index, :index
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
