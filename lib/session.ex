defmodule Bouncer.Session do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Plug.Conn
  alias Bouncer.Token

  @adapter Application.get_env(:bouncer, :adapter)

  @doc """
  Generates a session token. The ttl (time-to-live) defaults to 2 weeks.
  See Bouncer.Token.Generate/4.
  """
  def generate(conn, user, ttl \\ 1210000) do
    Token.generate(conn, "user", user, ttl)
  end

  @doc """
  Verifies a session token is valid and matches the given user. See
  Bouncer.Token.Verify/4.
  """
  def verify(conn, token), do: Token.verify(conn, "user", token)


  @doc """
  Saves session data given a key and optional ttl (time-to-live).
  """
  def save(data, key, ttl), do: @adapter.save(data, key, ttl)

  @doc """
  Retrieves session data given an authorization token and puts it into the
  connection.
  """
  def put_current_user(conn) do
    if Map.has_key? conn.private, :auth_token do
      conn |> verify(conn.private.auth_token) |> put_current_user(conn)
    else
      conn
    end
  end

  @doc """
  Puts the user session data into the connection.
  """
  def put_current_user({status, u}, conn) do
    if status === :ok, do: Conn.put_private(conn, :current_user, u), else: conn
  end

  @doc """
  Destroys a session given a token and a user ID.
  """
  def destroy(token, id), do: Token.delete(token, id)

  @doc """
  Destroys all sessions associated with a given user ID.
  """
  def destroy_all(conn, id), do: Token.delete_all(conn, "user", id)

  @doc """
  Convenience function to determine if the ID from the current_user in the
  request matches the given User ID.

  ## examples
      iex> Bouncer.Session.user_request? %{private: %{current_user: %{id: 1}}},
      ...> 1
      true
      iex> Bouncer.Session.user_request? %{private: %{current_user: %{id: 1}}},
      ...> "1"
      true
      iex> Bouncer.Session.user_request? %{private: %{current_user: %{id: 1}}},
      ...> "2"
      false
      iex> Bouncer.Session.user_request? %{private: %{}}, 1
      false
  """
  def user_request?(conn, id) do
    if is_bitstring(id), do: {id, _} = Integer.parse(id)
    Map.has_key?(conn.private, :current_user) &&
    Map.has_key?(conn.private.current_user, :id) &&
    conn.private.current_user.id == id
  end
end
