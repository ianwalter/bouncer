defmodule SessionTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Bouncer.RedixPool
  alias Bouncer.Adapters.Redis
  alias Bouncer.Session
  alias Bouncer.MockToken
  alias Bouncer.Plugs.Authorize

  doctest Bouncer.Session

  setup do
    on_exit fn -> RedixPool.command(~w(FLUSHALL)) end
    {:ok, conn: %Conn{}}
  end

  test "session is created", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      user = %{id: 1}
      {:ok, token} = Session.create conn, user

      assert Redis.all 1 == {:ok, [token]}
      assert {:ok, user} == Redis.get(token)
    end
  end

  test "user can be assigned to the connection", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      user = %{id: 1}
      {:ok, token} = Session.create conn, user

      conn = conn
      |> Conn.put_req_header("authorization", "Bearer: #{token}")
      |> Authorize.assign_auth_token
      |> Session.assign_current_user

      assert conn.assigns.current_user == user
    end
  end

  test "session is destroyed", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      {:ok, token} = Session.create conn, %{id: 1}
      
      assert {:ok, token} == Session.destroy token, 1
      assert Redis.all 1 == {:ok, []}
      assert {:error, nil} == Redis.get token
    end
  end

  test "all user sessions are destroyed", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      {:ok, tokenOne} = Session.create conn, %{id: 1}
      {:ok, tokenTwo} = Session.create conn, %{id: 1}

      Session.destroy_all conn, 1

      assert Redis.all 1 == {:ok, []}
      assert {:error, nil} == Redis.get tokenOne
      assert {:error, nil} == Redis.get tokenTwo
    end
  end
end
