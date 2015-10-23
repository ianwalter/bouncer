defmodule EmailVerificationTest do
  use ExUnit.Case

  alias Plug.Conn
  alias Bouncer.RedixPool
  alias Bouncer.Adapters.Redis
  alias Bouncer.MockEndpoint
  alias Bouncer.EmailVerification

  doctest Bouncer.Session

  setup do
    on_exit fn -> RedixPool.command(~w(FLUSHALL)) end
    {:ok, conn: %Conn{} |> Conn.put_private(:phoenix_endpoint, MockEndpoint)}
  end

  test "email verification token is generated", %{conn: conn} do
    user = %{id: 1}
    {:ok, token} = EmailVerification.generate conn, user

    assert {:ok, [token]} === Redis.all 1
    assert {:ok, user} === Redis.get token
  end

  test "email verification token is regenerated", %{conn: conn} do
    user = %{id: 4}
    {:ok, testToken} = EmailVerification.generate conn, user, 86400
    {:ok, newToken} = EmailVerification.regenerate conn, user, 86400

    assert {:error, nil} === Redis.get testToken
    assert {:ok, user} === Redis.get newToken
    assert {:ok, [newToken]} === Redis.all user.id
  end

  test "valid email verification token is verified", %{conn: conn} do
    user = %{id: 1}
    {:ok, token} = EmailVerification.generate conn, user, 86400
    assert {:ok, user} === EmailVerification.verify conn, token
  end

  test "invalid email verification token is not verified", %{conn: conn} do
    {:ok, token} = EmailVerification.generate conn, %{id: 1}, 86400
    assert {:error, "Invalid token"} === EmailVerification.verify conn, token
  end

  test "email verification token not verified when not stored", %{conn: conn} do
    token = Phoenix.Token.sign conn, "test", 1
    assert {:error, nil} === EmailVerification.verify conn, token
  end
end
