defmodule TokenTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Bouncer.Token
  alias Bouncer.RedixPool
  alias Bouncer.MockEndpoint
  alias Bouncer.Adapters.Redis

  setup do
    on_exit fn -> RedixPool.command(~w(FLUSHALL)) end
    {:ok, conn: %Conn{} |> Conn.put_private(:phoenix_endpoint, MockEndpoint)}
  end

  doctest Bouncer.Token

  test "token is generated", %{conn: conn} do
    assert {:ok, _} = Token.generate conn, "test", %{id: 1}, 86400
  end

  test "token is deleted", %{conn: conn} do
    user = %{id: 2}
    {:ok, token} = Token.generate conn, "test", user, 86400
    Token.delete token, user.id

    assert {:error, nil} == Redis.get token
    assert {:ok, []} == Redis.all user.id
  end

  test "token is regenerated and old tokens are deleted", %{conn: conn} do
    user = %{id: 3}
    {:ok, testToken} = Token.generate conn, "test", user, 86400
    {:ok, otherToken} = Token.generate conn, "other", user, 86400
    Token.delete_all conn, "test", user.id

    assert {:error, nil} == Redis.get testToken
    assert {:ok, [otherToken]} == Redis.all user.id
  end

  test "valid token is verified", %{conn: conn} do
    user = %{id: 1}
    {:ok, token} = Token.generate conn, "test", user, 86400
    assert user == Token.verify conn, token, "test"
  end

  test "invalid token is not verified", %{conn: conn} do
    {:ok, token} = Token.generate(conn, "test", %{id: 1}, 86400)
    refute Token.verify conn, token, "test"
  end
end
