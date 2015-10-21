defmodule Bouncer.Adapters.Redis do
  @moduledoc """
  The Redis adapter is used by Bouncer.Token to save and retrieve generated
  tokens and associated data.
  """

  @doc """
  Retrieves the Redis connection from the application config.
  """
  def redis, do: Application.get_env(:bouncer, :redis)

  @doc """
  Saves data to Redis using a given key. If ttl is not nil, the value  will be
  converted from seconds to miliseconds and set as the key's time-to-live.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW", nil
      {:ok, "UdOnTkNoW"}
      iex> Bouncer.Adapters.Redis.save %{id: 2}, nil, nil
      {:error, "wrong number of arguments"}
      iex> Bouncer.Adapters.Redis.save nil, 3, nil
      {:error, "wrong number of arguments"}
      iex> Bouncer.Adapters.Redis.save %{id: 2}, 2, 86400
      {:error, "Could not set TTL, key 2 not found"}
  """
  def save(data, key, ttl) do
    case {data, key} do
      {nil, _} -> {:error, "wrong number of arguments"}
      {_, nil} -> {:error, "wrong number of arguments"}
      {_, _} ->

        case redis.command(~w(SET) ++ [key] ++ [Poison.encode! data]) do
          {:ok, _} ->

            if ttl do
              case redis.command(~w(EXPIRE) ++ [key] ++ [ttl * 1000]) do
                {:ok, 1} -> {:ok, key}
                {:ok, 0} -> {:error, "Could not set TTL, key #{key} not found"}
                {_, response} -> {:error, response}
              end
            end

          {_, response} -> {:error, response}
        end

    end
  end

  @doc """
  Retrieves data from Redis using a given key.

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
  Adds a token to a user's collection of tokens.

  ## Examples
      iex> Bouncer.Adapters.Redis.add 1, "UdOnTkNoW"
      {:ok, 1}
  """
  def add(id, token) do
    case redis.command(~w(SADD) ++ [id] ++ [token]) do
      {:error, error} -> {:error, error.message}
      response -> response
    end
  end

  @doc """
  Retrieves a user's collection of tokens given their ID.

  ## Examples
      iex> Bouncer.Adapters.Redis.all 1
      {:ok, ["UdOnTkNoW"]}
      iex> Bouncer.Adapters.Redis.all 2
      {:ok, []}
  """
  def all(id) do
    case redis.command(~w(SMEMBERS) ++ [id]) do
      {:error, error} -> {:error, error.message}
      response -> response
    end
  end

  @doc """
  """
  def remove(key, index), do: redis.command(~w(SREM) ++ [key] ++ [index])

  @doc """
  Deletes given key(s) from Redis.

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
      {:ok, 1} -> {:ok, key}
      {_, response} -> {:error, response}
    end
  end
end
