# Download4pda

This little server allows downloading files from 4pda as a guest.

It's a test elixir project, so "this ain't much and it **doesn't work**" -- cloudflare beat me on site protection :D.

The main how-to stuff you can get from here are:

  * custom phoenix configs (config/config.exs:28)
  * custom temporary links (lib/download_4pda/downloads/temp_links.ex:1)
  * phoenix proxy-like streaming with httpoison (lib/download_4pda_web/controllers/file_download_controller.ex:8)

## Development server

To start development Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

## Learn more about phoenix

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
