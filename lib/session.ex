defmodule Bouncer.Session do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Plug.Conn
  alias Phoenix.Token

  @doc """
  Retrieves the specified session store adapter from the application config.
  """
  def adapter, do: Application.get_env(:bouncer, :adapter)

  @doc """
  Creates a session for a given user and saves it to the session store. Returns
  the session token which will be used as the API authorization token.
  """
  def create(conn, user) do
    user |> adapter.save(Token.sign(conn, "user", user.id))
  end

  @doc """
  Retrieves session data given an authorization token and assigns it to the
  connection.
  """
  def assign_current_user(conn) do
    if Map.has_key? conn.assigns, :auth_token do
      conn.assigns.auth_token
      |> adapter.get
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
      {:ok, user = %{id: id}} ->
        case Token.verify(conn, "user", conn.assigns.auth_token) do
          {:ok, ^id} -> user
          _ -> nil
        end
      _ -> nil
    end
  end

  @doc """
  Destroys a session by removing session data from the store.
  """
  def destroy(key), do: adapter.delete(key)

  @doc """
  Convenience function to determine if the ID from the current_user in the
  request matches the given User ID.

  ## examples
      iex> Bouncer.Session.user_request? %{assigns: %{current_user: %{id: 1}}}, 1
      true
      iex> Bouncer.Session.user_request? %{assigns: %{current_user: %{id: 1}}}, 2
      false
      iex> Bouncer.Session.user_request? %{assigns: %{}}, 1
      false
  """
  def user_request?(conn, id) do
    Map.has_key?(conn.assigns, :current_user) &&
    Map.has_key?(conn.assigns.current_user, :id) &&
    conn.assigns.current_user.id === id
  end
end
