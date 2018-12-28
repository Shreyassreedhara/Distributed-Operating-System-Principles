defmodule TestWeb.PageController do
  use TestWeb, :controller

  def index(conn, _params) do
    spawn fn -> Bitcoin.main end
    render(conn, "index.html")
  end
end
 