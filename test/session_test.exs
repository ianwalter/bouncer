defmodule SessionTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Bouncer.Session
  alias Bouncer.MockToken

  doctest Bouncer.Session

  setup do
    { :ok, conn: %Conn{} }
  end

  test "session is created", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert { :ok, "UdOnTkNoW" } = Session.create(conn, %{id: 1})
    end
  end

  test "session can be retrieved", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert { :ok, %{id: 1} } = Session.get(conn, "UdOnTkNoW")
    end
  end

  test "session is destroyed" do
    with_mock Phoenix.Token, MockToken.keyword_list do
      assert { :ok, "UdOnTkNoW" } = Session.destroy("UdOnTkNoW")
    end
  end
end
