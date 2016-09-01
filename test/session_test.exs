defmodule SessionTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Bouncer.RedixPool
  alias Bouncer.Adapters.Redis
  alias Bouncer.Session
  alias Bouncer.MockEndpoint
  alias Bouncer.Plugs.Authorize

  doctest Bouncer.Session

  setup do
    RedixPool.command ~w(FLUSHALL)
    {:ok, conn: %Conn{} |> Conn.put_private(:phoenix_endpoint, MockEndpoint)}
  end

  test "session is generated", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, token} = Session.generate conn, user

    assert {:ok, [token]} === Redis.all 1
    assert {:ok, user} === Redis.get token
  end

  test "current_user can be put into the connection", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, token} = Session.generate conn, user

    conn = conn
    |> Conn.put_req_header("authorization", "Bearer #{token}")
    |> Authorize.put_auth_token
    |> Session.put_current_user

    assert conn.private.current_user == user
  end

  test "session is destroyed", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, token} = Session.generate conn, user

    assert {:ok, 1} === Session.destroy token, user["id"]
    assert {:ok, []} === Redis.all user["id"]
    assert {:error, nil} === Redis.get token
  end

  test "all user sessions are destroyed", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, tokenOne} = Session.generate conn, user
    {:ok, tokenTwo} = Session.generate conn, user

    Session.destroy_all conn, user["id"]

    assert {:ok, []} === Redis.all 1
    assert {:error, nil} === Redis.get tokenOne
    assert {:error, nil} === Redis.get tokenTwo
  end
end
