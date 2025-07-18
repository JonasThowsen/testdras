defmodule DrasMvpWeb.PageController do
  use DrasMvpWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
