defmodule Bouncer.Session do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Plug.Conn

  @doc """
  Makes the adapter specified in the environment configuration available.
  """
  def adapter, do: Application.get_env(:bouncer, :adapter)

  @doc """
  Creates a session for a given user and saves it to the session store.
  """
  def create(conn, user) do
    Poison.encode! user
    |> save(Phoenix.Token.sign(conn, "user", user.id))
  end

  @doc """
  Saves session data to the session store using a key.
  """
  def save(data, key), do: adapter.save(data, key)

  @doc """
  Retrieves session data given a token (key) and assigns it to the connection.
  """
  def get(conn, token) do
    case Phoenix.Token.verify(conn, "user", token) do
      { :ok, id } ->
        conn = Conn.assign(conn, :user_token, token)

        token
        |> adapter.get
        |> parse_data
        |> verify_user_match(id)
      _ -> { :error, "Could not verify token" }
    end
  end

  @doc """
  Parses JSON session data retrieved from the store into a map.

  ## Examples
      iex> Bouncer.Session.parse_data({ :ok, ~s({"id": 1}) })
      { :ok, %{id: 1} }
      iex> Bouncer.Session.parse_data({ :error, nil })
      { :error, nil }
      iex> Bouncer.Session.parse_data({ :ok, "" })
      { :error, :invalid }
  """
  def parse_data({ status, response }) do
    case status do
      :ok ->
        case Poison.Parser.parse response, keys: :atoms! do
          { :ok, data} -> { :ok, data }
          { status, response } -> { :error, response }
        end
      status -> { status, response }
    end
  end

  @doc """
  Verifies that the ID deciphered from the received token matches the ID in the
  session data.

  ## Examples
      iex> Bouncer.Session.verify_user_match({ :ok, %{id: 1} }, 1)
      { :ok, %{id: 1} }
      iex> Bouncer.Session.verify_user_match({ :ok, %{id: 2} }, 1)
      { :error, "Token ID does not match session data ID" }
      iex> Bouncer.Session.verify_user_match({ :error, nil }, 1)
      { :error, nil }
  """
  def verify_user_match({ status, response }, id) do
    case status do
      :ok ->
        if Map.has_key?(response, :id) && response.id === id do
          { :ok, response }
        else
          { :error, "Token ID does not match session data ID"}
        end
      status -> { status, response }
    end
  end

  @doc """
  Destroys a session by removing session data from the store.
  """
  def destroy(key), do: adapter.delete(key)
end
