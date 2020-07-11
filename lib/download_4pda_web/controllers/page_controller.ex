defmodule Download4pdaWeb.PageController do
  use Download4pdaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
