defmodule HawkWeb.PageController do
  use HawkWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
