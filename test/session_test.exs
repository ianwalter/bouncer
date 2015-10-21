defmodule SessionTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Bouncer.Session
  alias Bouncer.MockToken
  alias Bouncer.Plugs.Authorize

  doctest Bouncer.Session

  setup do
    {:ok, conn: %Conn{}}
  end

  test "session is created", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert {:ok, "UdOnTkNoW"} = Session.create(conn, %{id: 1})
    end
  end

  test "session can be retrieved", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      conn = conn
      |> Conn.put_req_header("authorization", "Bearer: UdOnTkNoW")
      |> Authorize.assign_auth_token

      expected_response =  %Conn{assigns: %{current_user: %{id: 1}}}

      assert expected_response = Session.assign_current_user(conn)
    end
  end

  test "session is destroyed" do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert {:ok, "UdOnTkNoW"} = Session.destroy("UdOnTkNoW", 1)
    end
  end
end
