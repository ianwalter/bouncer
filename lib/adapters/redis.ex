defmodule Bouncer.Adapters.Redis do
  @moduledoc """
  The Redis adapter can be used by Bouncer.Session to store, retrieve, and
  destroy session data within Redis.
  """

  @doc """
  Retrieves the Redis connection from the application config.
  """
  def redis, do: Application.get_env(:bouncer, :redis)

  @doc """
  Saves session data to Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW"
      {:ok, "UdOnTkNoW"}
      iex> Bouncer.Adapters.Redis.save %{id: 2}, nil
      {:error, "wrong number of arguments"}
      iex> Bouncer.Adapters.Redis.save nil, 3
      {:error, "wrong number of arguments"}
  """
  def save(data, key) do
    case {data, key} do
      {nil, _} -> {:error, "wrong number of arguments"}
      {_, nil} -> {:error, "wrong number of arguments"}
      {_, _} ->
        case redis.command(~w(SET) ++ [key] ++ [Poison.encode! data]) do
          {:ok, _} -> {:ok, key}
          {_, response} -> {:error, response}
        end
    end
  end

  @doc """
  Retrieves session data from Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.get "UdOnTkNoW"
      {:ok, %{id: 1}}
      iex> Bouncer.Adapters.Redis.get "test"
      {:error, nil}
      iex> Bouncer.Adapters.Redis.get nil
      {:error, "wrong number of arguments"}
  """
  def get(key) do
    case redis.command(~w(GET) ++ [key]) do
      {:ok, nil}  -> {:error, nil}
      {:ok, data} -> {:ok, Poison.Parser.parse!(data, keys: :atoms!)}
      {_, response} -> {:error, response}
    end
  end

  @doc """
  Destroys a session by removing the data from Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.delete 1
      {:ok, 1}
      iex> Bouncer.Adapters.Redis.delete 2
      {:error, 0}
      iex> Bouncer.Adapters.Redis.delete nil
      {:error, "wrong number of arguments"}
  """
  def delete(key) do
    case redis.command(~w(DEL) ++ [key]) do
      {:ok, ^key} -> {:ok, key}
      {_, response} -> {:error, response}
    end
  end
end
