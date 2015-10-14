defmodule Bouncer.Adapters.Redis do
  @moduledoc """
  The Redis adapter can be used by Bouncer.Session to store, retrieve, and
  destroy session data within Redis.
  """

  def redis do
    Application.get_env(:bouncer, :redis)
  end

  @doc """
  Saves session data to Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.save(~s({"id": 1}), 1)
      { :ok, "OK" }
      iex> Bouncer.Adapters.Redis.save(~s({"id": 2}), nil)
      { :error, "wrong number of arguments" }
      iex> Bouncer.Adapters.Redis.save(nil, 3)
      { :error, "wrong number of arguments" }
  """
  def save(data, key) do
    case redis().command(~w(SET) ++ [key] ++ [data]) do
      { :ok, response } -> { :ok, response }
      { _, response } -> { :error, response }
    end
  end

  @doc """
  Retrieves session data from Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.get(1)
      { :ok, ~s("id": 1) }
      iex> Bouncer.Adapters.Redis.get(2)
      { :error, nil }
      iex> Bouncer.Adapters.Redis.get(nil)
      { :error, "wrong number of arguments" }
  """
  def get(key) do
    case redis().command(~w(GET) ++ [key]) do
      { :ok, nil } -> { :error, nil }
      { :ok, data } -> { :ok, data }
      { _, response } -> { :error, response }
    end
  end

  @doc """
  Destroys a session by removing the data from Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.delete(1)
      { :ok, 1 }
      iex> Bouncer.Adapters.Redis.delete(2)
      { :error, 0 }
      iex> Bouncer.Adapters.Redis.delete(nil)
      { :error, "wrong number of arguments" }
  """
  def delete(key) do
    case redis().command(~w(DEL) ++ [key]) do
      { :ok, ^key } -> { :ok, key }
      { _, response } -> { :error, response }
    end
  end
end
