defmodule Bouncer.Session do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Plug.Conn
  alias Bouncer.Token

  @adapter Application.get_env(:bouncer, :adapter)

  @doc """
  Generates a token, saves it to a data store, and adds it to the user's list of
  tokens. The returned token can be used as the API authorization token. Default
  time-to-live for the token is 2 weeks (in seconds).
  """
  def create(conn, user, ttl \\ 1.21e+6) do
    Token.generate(conn, "user", user, ttl)
  end

  @doc """
  Retrieves session data given an authorization token and assigns it to the
  connection.
  """
  def assign_current_user(conn) do
    if Map.has_key? conn.assigns, :auth_token do
      conn.assigns.auth_token
      |> @adapter.get
      |> user_matches?(conn)
      |> assign_current_user(conn)
    else
      conn
    end
  end

  @doc """
  Assigns the user session data to the connection.
  """
  def assign_current_user(user, conn) do
    if user, do: Conn.assign(conn, :current_user, user), else: conn
  end

  @doc """
  Verifies that the ID deciphered from the received token matches the ID in the
  session data.
  """
  def user_matches?(response, conn) do
    case response do
      {:ok, user} -> Token.verify(conn, "user", user, conn.assigns.auth_token)
      _ -> nil
    end
  end

  @doc """
  Destroys a session given a token and a user ID.
  """
  def destroy(token, id), do: Token.delete(token, id)

  @doc """
  Destroys all sessions associated with a given user ID.
  """
  def destroy_all(id), do: Token.delete_all("user", id)

  @doc """
  Convenience function to determine if the ID from the current_user in the
  request matches the given User ID.

  ## examples
      iex> Bouncer.Session.user_request? %{assigns: %{current_user: %{id: 1}}},
      ...> 1
      true
      iex> Bouncer.Session.user_request? %{assigns: %{current_user: %{id: 1}}},
      ...> "1"
      true
      iex> Bouncer.Session.user_request? %{assigns: %{current_user: %{id: 1}}},
      ...> "2"
      false
      iex> Bouncer.Session.user_request? %{assigns: %{}}, 1
      false
  """
  def user_request?(conn, id) do
    if is_bitstring(id), do: {id, _} = Integer.parse(id)
    Map.has_key?(conn.assigns, :current_user) &&
    Map.has_key?(conn.assigns.current_user, :id) &&
    conn.assigns.current_user.id == id
  end
end
