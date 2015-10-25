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
    user = %{id: 1}
    assert {:ok, token} = Token.generate conn, "test", user, 86400
    assert {:ok, user} === Redis.get token
    assert {:ok, [token]} === Redis.all user.id
  end

  test "token is deleted", %{conn: conn} do
    user = %{id: 2}
    {:ok, token} = Token.generate conn, "test", user, 86400
    Token.delete token, user.id

    assert {:error, nil} === Redis.get token
    assert {:ok, []} === Redis.all user.id
  end

  test "all tokens of namespace are deleted", %{conn: conn} do
    user = %{id: 3}
    {:ok, testToken} = Token.generate conn, "test", user, 86400
    {:ok, secondToken} = Token.generate conn, "test", user, 86400
    {:ok, otherToken} = Token.generate conn, "other", user, 86400
    Token.delete_all conn, "test", user.id

    assert {:error, nil} === Redis.get testToken
    assert {:error, nil} === Redis.get secondToken
    assert {:ok, [otherToken]} === Redis.all user.id
  end

  test "token is regenerated and old tokens are deleted", %{conn: conn} do
    user = %{id: 4}
    {:ok, testToken} = Token.generate conn, "test", user, 86400
    {:ok, newToken} = Token.regenerate conn, "test", user, 86400

    assert {:error, nil} === Redis.get testToken
    assert {:ok, user} === Redis.get newToken
    assert {:ok, [newToken]} === Redis.all user.id
  end

  test "valid token is verified", %{conn: conn} do
    user = %{id: 1}
    {:ok, token} = Token.generate conn, "test", user, 86400
    assert {:ok, user} === Token.verify conn, "test", token
  end

  test "invalid token is not verified", %{conn: conn} do
    {:ok, token} = Token.generate conn, "test", %{id: 1}, 86400
    assert {:error, "Invalid token"} === Token.verify conn, "other", token
  end

  test "token not verified when not stored", %{conn: conn} do
    token = Phoenix.Token.sign conn, "test", 1
    assert {:error, nil} === Token.verify conn, "test", token
  end
end
