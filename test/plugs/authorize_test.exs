defmodule Plugs.AuthorizeTest do
  use ExUnit.Case

  alias Plug.Conn

  doctest Bouncer.Plugs.Authorize

  setup do
    { :ok, conn: %Conn{} }
  end

  test "no data is added when no auth header is specified", %{conn: conn} do
    conn = Bouncer.Plugs.Authorize.call(conn, nil)
    assert Map.has_key?(conn.assigns, :current_user) == false
  end

  test "no data is added when bogus auth header is specified", %{conn: conn} do
    conn = conn
    |> Conn.put_req_header("authorization", "Bearer: test")
    |> Bouncer.Plugs.Authorize.call(nil)

    assert Map.has_key?(conn.assigns, :current_user) == false
  end
end
