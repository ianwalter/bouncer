defmodule PasswordResetTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Bouncer.RedixPool
  alias Bouncer.Adapters.Redis
  alias Bouncer.MockEndpoint
  alias Bouncer.PasswordReset
  alias Bouncer.Token

  doctest Bouncer.Session

  setup do
    RedixPool.command ~w(FLUSHALL)
    {:ok, conn: %Conn{} |> Conn.put_private(:phoenix_endpoint, MockEndpoint)}
  end

  test "password reset token is generated", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, token} = PasswordReset.generate conn, user

    assert {:ok, [token]} === Redis.all 1
    assert {:ok, user} === Redis.get token
  end

  test "password reset token is regenerated", %{conn: conn} do
    user = %{"id" => 2}
    {:ok, testToken} = PasswordReset.generate conn, user, 86400
    :timer.sleep(1)
    {:ok, newToken} = PasswordReset.regenerate conn, user, 86400

    assert {:error, nil} === Redis.get testToken
    assert {:ok, user} === Redis.get newToken
    assert {:ok, [newToken]} === Redis.all user["id"]
  end

  test "valid password reset token is verified", %{conn: conn} do
    user = %{"id" => 1}
    {:ok, token} = PasswordReset.generate conn, user, 86400
    assert {:ok, user} === PasswordReset.verify conn, token
  end

  test "invalid password reset token is not verified", %{conn: conn} do
    {:ok, token} = Token.generate conn, "test", %{"id" => 1}, 86400
    assert {:error, "Invalid token"} === PasswordReset.verify conn, token
  end

  test "password reset token not verified when not stored", %{conn: conn} do
    token = Phoenix.Token.sign conn, "password", 1
    assert {:error, nil} === PasswordReset.verify conn, token
  end
end
