defmodule Bouncer.Plugs.Authorize do
  @moduledoc """
  The Authorize plug can be used to scan a connection for an authorization
  token and use it to retrieve a user session so it can be added to the
  connection.
  """

  alias Plug.Conn
  alias Bouncer.Session

  @doc """
  """
  def init(options) do
    options
  end

  @doc """
  Scans a connection for an authroization token, uses the token to retrieve
  a user, adds it to the connection, and returns the connection.
  """
  def call(conn, _) do
    token = conn |> get_authorization_header |> get_authorization_token

    case conn |> Session.get(token) |> add_user_to_connection(conn) do
      { :ok, conn } -> conn
      { :error, _ } ->
        # TODO Log error
        conn
    end
  end

  @doc """
  Returns the value of the request authorization header.
  """
  def get_authorization_header(conn) do
    List.first(Conn.get_req_header(conn, "authorization"))
  end

  @doc """
  Pulls the authorization token out of the request header value.

  ## Examples
      iex> Bouncer.Plugs.Authorize.get_authorization_token("Bearer: test")
      "test"
      iex> Bouncer.Plugs.Authorize.get_authorization_token(nil)
      nil
  """
  def get_authorization_token(header_value) do
    case header_value do
      nil -> nil
      header_value -> List.last(String.split(header_value, "Bearer: "))
    end
  end

  @doc """
  Adds the user's session data to the connection so that the controller actions
  that use the plug can determine what to do with the information.
  """
  def add_user_to_connection({ status, response }, conn) do
    case status do
      :ok -> { :ok, Conn.assign(conn, :current_user, response) }
      _ -> { status, response }
    end
  end
end
