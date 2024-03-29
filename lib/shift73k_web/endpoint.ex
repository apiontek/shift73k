defmodule Shift73kWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :shift73k

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_shift73k_key",
    signing_salt: "9CKxo0VJ"
  ]

  socket "/socket", Shift73kWeb.UserSocket,
    websocket: true,
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  #
  # file list generated by simple ls -1 assets/static/ - then copy/paste here
  plug Plug.Static,
    at: "/",
    from: :shift73k,
    gzip: false,
    only: ~w(assets
      android-chrome-192x192.png
      android-chrome-512x512.png
      apple-touch-icon.png
      browserconfig.xml
      favicon-16x16.png
      favicon-32x32.png
      favicon.ico
      mstile-144x144.png
      mstile-150x150.png
      mstile-310x150.png
      mstile-310x310.png
      mstile-70x70.png
      robots.txt
      safari-pinned-tab.svg
      site.webmanifest)

  # For using vite.js in dev, we need to instruct Phoenix to serve files at assets/src over the usual endpoint. This is only necessary in development.
  if Mix.env() == :dev do
    plug Plug.Static,
      at: "/",
      from: "assets",
      gzip: false
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :shift73k
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug Shift73kWeb.Router
end
