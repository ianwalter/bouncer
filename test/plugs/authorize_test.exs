defmodule Plugs.AuthorizeTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Bouncer.Plugs.Authorize
  alias Bouncer.MockEndpoint
  alias Bouncer.RedixPool
  alias Bouncer.Session

  doctest Bouncer.Plugs.Authorize

  setup do
    RedixPool.command ~w(FLUSHALL)
    {:ok, conn: %Conn{} |> Conn.put_private(:phoenix_endpoint, MockEndpoint)}
  end

  test "no data is added when no auth header received", %{conn: conn} do
    conn = Authorize.call(conn, nil)

    refute Map.has_key?(conn.private, :auth_token)
    refute Map.has_key?(conn.private, :current_user)
  end

  test "no user data is added when bogus auth token received", %{conn: conn} do
    conn = conn
    |> Conn.put_req_header("authorization", "Bearer: test")
    |> Authorize.call(nil)

    refute Map.has_key?(conn.private, :current_user)
  end

  test "user data is added when correct auth header is specified",
    %{conn: conn} do

    user = %{"id" => 1}
    {:ok, token} = Session.generate conn, user

    conn = conn
    |> Conn.put_req_header("authorization", "Bearer: #{token}")
    |> Bouncer.Plugs.Authorize.call(nil)

    assert conn.private.auth_token == token
    assert conn.private.current_user == user

  end
end
