defmodule Bouncer.Token do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Phoenix.Token

  @adapter Application.get_env(:bouncer, :adapter)

  @doc """
  Generates a token, uses it as a key to save user data to the store, and
  associates it with the user's ID.
  """
  def generate(conn, namespace, user, ttl) do
    token = Token.sign(conn, namespace, user.id)
    case @adapter.save(user, token, ttl) do

      {:ok, ^token} ->
        case @adapter.add(user.id, token) do
          {:ok, _} -> {:ok, token}
          response -> response
        end

      response -> response

    end
  end

  @doc """
  Verifies that a given token is valid. Returns data retrieved from the store
  using the token as a key if token is valid.
  """
  def verify(conn, namespace, token) do
    case validate([conn, namespace, token]) do
      ^token -> @adapter.get(token)
      false -> {:error, "Invalid token"}
    end
  end

  @doc """
  Validates a token against a given namespace. Returns the token if valid and
  false otherwise.
  """
  def validate([conn, namespace, token]) do
    case Token.verify(conn, namespace, token) do
      {:ok, _} -> token
      _ -> false
    end
  end

  @doc """
  Gets rid of any existing tokens given a namespace and user ID. Generates and
  returns a new token.
  """
  def regenerate(conn, namespace, user, ttl) do
    delete_all(conn, namespace, user.id)
    generate(conn, namespace, user, ttl)
  end

  @doc """
  Deletes all tokens of a given namespace and disassociates them with the given
  user's ID.
  """
  def delete_all(conn, namespace, id) do
    {_, tokens} = @adapter.all(id)
    Enum.map(tokens, &([conn, namespace, &1]))
    |> Enum.filter_map(&validate/1, fn ([_, _, token]) -> token end)
    |> delete(id)
  end

  @doc """
  Deletes token(s) and disassociates them with the given user's ID.
  """
  def delete(token, id) do
    @adapter.delete(token)
    @adapter.remove(id, token)
  end
end
