defmodule TokenTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Bouncer.Token
  alias Bouncer.MockToken
  alias Bouncer.RedixPool

  setup do
    on_exit fn -> RedixPool.command(~w(FLUSHALL)) end
    {:ok, conn: %Conn{}}
  end

  test "token is generated", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert {:ok, "UdOnTkNoW"} = Token.generate(conn, "test", %{id: 1}, 86400)
    end
  end

  test "valid token is verified", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      {:ok, token} = Token.generate(conn, "test", user, 86400)
      assert user = Token.verify(conn, "test", user, token)
    end
  end

  test "invalid token is not verified", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      user = %{id: 1}
      {:ok, token} = Token.generate(conn, "test", user, 86400)
      assert nil = Token.verify(conn, "test", %{id: 2}, token)
    end
  end
end
