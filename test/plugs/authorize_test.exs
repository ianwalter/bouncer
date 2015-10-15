defmodule Plugs.AuthorizeTest do
  use ExUnit.Case

  import Mock

  alias Plug.Conn
  alias Bouncer.Plugs.Authorize
  alias Bouncer.MockToken

  doctest Bouncer.Plugs.Authorize

  setup do
    { :ok, conn: %Conn{} }
  end

  test "no data is added when no auth header is specified", %{conn: conn} do
    conn = Authorize.call(conn, nil)
    refute Map.has_key?(conn.assigns, :current_user)
  end

  test "no data is added when bogus auth header is specified", %{conn: conn} do
    with_mock Phoenix.Token, MockToken.keyword_list do
      conn = conn
      |> Conn.put_req_header("authorization", "Bearer: test")
      |> Authorize.call(nil)

      refute Map.has_key?(conn.assigns, :current_user)
    end
  end

  # test "session data is added when correct auth header is specified",
  #   %{conn: conn, token: token} do
  #
  #   with_mock Phoenix.Token, token do
  #     conn = conn
  #     |> Conn.put_req_header("authorization", "Bearer: UdOnTkNoW")
  #     |> Bouncer.Plugs.Authorize.call(nil)
  #
  #     assert Map.has_key?(conn.assigns, :current_user)
  #   end
  #
  # end
end
