defmodule Bouncer.Token do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Phoenix.Token

  @adapter Application.get_env(:bouncer, :adapter)

  @doc """
  Generates a token, saves it to a data store, and adds it to the user's list of
  tokens.
  """
  def generate(conn, namespace, user, ttl) do
    id = user.id
    token = Token.sign(conn, namespace, id)
    case @adapter.save(user, token, ttl) do
      {:ok, ^token} ->
        case @adapter.add(id, token) do
          {:ok, ^id} -> {:ok, token}
          {_, response} -> {:error, response}
        end

      {_, response} -> {:error, response}
    end
  end

  @doc """
  Verifies that a given token is valid and matches a given user's ID. Returns
  the given user.
  """
  def verify(conn, namespace, user, token) do
    id = user.id
    case Token.verify(conn, namespace, token) do
      {:ok, ^id} -> user
      _ -> nil
    end
  end

  @doc """
  Verifies that a given token is valid. Returns the token.
  """
  def verify(conn, namespace) do
    fn (token) ->
      case Token.verify(conn, namespace, token) do
        {:ok, _} -> token
        _ -> nil
      end
    end
  end

  @doc """
  Gets rid of any existing tokens given a namespace and user ID. Generates and
  returns a new token.
  """
  def regenerate(conn, namespace, id, ttl) do
    conn |> delete_all(namespace, id) |> generate(namespace, id, ttl)
  end

  @doc """
  Deletes and removes from a user's list of tokens all tokens of a given
  namespace. Returns the connection.
  """
  def delete_all(conn, namespace, id) do
    Enum.map(@adapter.all(id), verify(conn, namespace)) |> delete(id)
    conn
  end

  @doc """
  Deletes a token and removes it from the user's list of tokens.
  """
  def delete(token, id) do
    @adapter.remove(id, token)
    @adapter.delete(token)
  end
end
