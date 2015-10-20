defmodule Bouncer.Token do
  @moduledoc """
  A library of functions used to work with session data.
  """

  alias Phoenix.Token

  @adapter Application.get_env(:bouncer, :adapter)

  @doc """

  """
  def generate(conn, namespace, id, ttl) do
    token = Token.sign(conn, namespace, id)
    case @adapter.save(token, %{id: id}, ttl) do
      {:ok, ^token} ->
        case @adapter.add(id, token) do
          {:ok, ^id} -> {:ok, token}
          {_, response} -> {:error, response}
        end

      {_, response} -> {:error, response}
    end
  end

  @doc """

  """
  def verify(conn, namespace, id, token) do
    case Token.verify(conn, namespace, token) do
      {:ok, ^id} -> {:ok, id}
      {_, response} -> {:error, response}
    end
  end

  @doc """

  """
  def regenerate(conn, namespace, id) do
    {:ok, collection} = @adapter.collect(id)

    case verify(conn, namespace, id, token) do
      {:ok, _} -> @adapter.delete(token)
    end

    # Generate a new token
    generate(conn, namespace, id)
  end
end
