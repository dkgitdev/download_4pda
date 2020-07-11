# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :download_4pda, Download4pdaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q5asnPgiaI1AH+0/5lHpe/f5bQV0YrmEZbI+vzcfitte5r7GGZJZjXt7PRL7agk4",
  render_errors: [view: Download4pdaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Download4pda.PubSub,
  live_view: [signing_salt: "bPGk8e0t"]

request_options =
  if System.get_env("SOCKS5_PROXY_HOST") && System.get_env("SOCKS5_PROXY_PORT") do
    with host <- String.to_charlist(System.get_env("SOCKS5_PROXY_HOST")),
         {port, ""} <- Integer.parse(System.get_env("SOCKS5_PROXY_PORT")) do
      [proxy: {:socks5, host, port}]
    end
  else
    []
  end

config :download_4pda,
  request_options: request_options,
  request_headers: [
    {
      "accept-language",
      "ru-RU,ru;q=0.8,en-US;q=0.6,en;q=0.4"
    },
    {
      "user-agent",
      "Mozilla/5.0 (Linux; Android 4.4; Nexus 5 Build/_BuildID_) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/30.0.0.0 Mobile Safari/537.36"
    },
    {
      "accept-encoding",
      "gzip"
    },
    {"cookie", System.get_env("COOKIES") || ""},
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
