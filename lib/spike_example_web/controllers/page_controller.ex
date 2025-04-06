defmodule SpikeExampleWeb.PageController do
  use SpikeExampleWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
