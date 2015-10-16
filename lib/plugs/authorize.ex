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
  Extracts an authorization token from the request header and adds it back into
  the connection. Retreives a user's session information from the session store
  using the authorization token and adds that information back into the
  connection.
  """
  def call(conn, _) do
    conn |> assign_auth_token |> Session.assign_current_user
  end

  @doc """
  Extracts the authorization header from the connection, extracts the
  authorization token from the header, and finally adds the token to the
  connection.
  """
  def assign_auth_token(conn) do
    conn |> get_auth_header |> get_auth_token |> assign_auth_token(conn)
  end

  @doc """
  Assigns the extracted authorization token to the connection.
  """
  def assign_auth_token(token, conn) do
    if token, do: Conn.assign(conn, :auth_token, token), else: conn
  end

  @doc """
  Extracts the value of the request authorization header.
  """
  def get_auth_header(conn) do
    List.first(Conn.get_req_header(conn, "authorization"))
  end

  @doc """
  Extracts the authorization token out of the request header value.

  ## Examples
      iex> Bouncer.Plugs.Authorize.get_auth_token "Bearer: test"
      "test"
      iex> Bouncer.Plugs.Authorize.get_auth_token nil
      nil
  """
  def get_auth_token(header_value) do
    if header_value, do: List.last(String.split(header_value, "Bearer: "))
  end
end
