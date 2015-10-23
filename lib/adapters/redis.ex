defmodule Bouncer.Adapters.Redis do
  @moduledoc """
  The Redis adapter is used by Bouncer.Token to save and retrieve generated
  tokens and associated data.
  """

  alias Bouncer.RedixPool

  @doc """
  Saves data to Redis using a given key. If ttl is not nil, the value  will be
  converted from seconds to miliseconds and set as the key's time-to-live.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW", nil
      {:ok, "UdOnTkNoW"}
  """
  def save(data, key, ttl) do
    {status, _} = RedixPool.command(~w(SET) ++ [key] ++ [Poison.encode! data])
    if ttl, do: expire(key, ttl), else: {status, key}
  end

  @doc """
  Sets the TTL (time-to-live in seconds) of the given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW", nil
      ...> Bouncer.Adapters.Redis.expire "UdOnTkNoW", 1
      {:ok, "UdOnTkNoW"}
      iex> Bouncer.Adapters.Redis.expire "Arcadia", 1
      {:error, "Could not set TTL, key 'Arcadia' not found"}
  """
  def expire(key, ttl) do
    case RedixPool.command(~w(EXPIRE) ++ [key] ++ [ttl * 1000]) do
      {:ok, 1} -> {:ok, key}
      {:ok, 0} -> {:error, "Could not set TTL, key '#{key}' not found"}
    end
  end

  @doc """
  Retrieves data from Redis using a given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1},"UdOnTkNoW", nil
      ...> Bouncer.Adapters.Redis.get "UdOnTkNoW"
      {:ok, %{id: 1}}
      iex> Bouncer.Adapters.Redis.get "Arcadia"
      {:error, nil}
  """
  def get(key) do
    case RedixPool.command(~w(GET) ++ [key]) do
      {_, nil}  -> {:error, nil}
      {_, data} -> {:ok, Poison.Parser.parse!(data, keys: :atoms!)}
    end
  end

  @doc """
  Adds item(s) to a Redis list identified by the given key.

  ## Examples
      iex> Bouncer.Adapters.Redis.add 1, "Arcadia"
      {:ok, 1}
  """
  def add(id, token), do: RedixPool.command(~w(SADD) ++ [id] ++ [token])

  @doc """
  Retrieves a user's collection of tokens given their ID.

  ## Examples
      iex> Bouncer.Adapters.Redis.add 1, "UdOnTkNoW"
      ...> Bouncer.Adapters.Redis.add 1, "Arcadia"
      ...> Bouncer.Adapters.Redis.all 1
      {:ok, ["UdOnTkNoW", "Arcadia"]}
      iex> Bouncer.Adapters.Redis.add 2, "divine_hammer"
      ...> Bouncer.Adapters.Redis.all 2
      {:ok, ["divine_hammer"]}
      iex> Bouncer.Adapters.Redis.all 3
      {:ok, []}
  """
  def all(id) do
    case RedixPool.command(~w(SMEMBERS) ++ [id]) do
      {_, members} when members === nil -> {:ok, []}
      {_, members} when is_bitstring(members) -> {:ok, [members]}
      {_, members} -> {:ok, members}
    end
  end

  @doc """
  Removes item(s) from the Redis list identified by a given key.
  """
  def remove(key, items) when is_list(items) do
    RedixPool.command(~w(SREM) ++ [key] ++ items)
  end

  @doc """
  Removes a item from the Redis list identified by a given key.
  """
  def remove(key, item), do: RedixPool.command(~w(SREM) ++ [key] ++ [item])

  @doc """
  Deletes given key(s) from Redis.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW", nil
      ...> Bouncer.Adapters.Redis.save %{id: 2}, "Arcadia", nil
      ...> Bouncer.Adapters.Redis.delete ["UdOnTkNoW", "Arcadia"]
      {:ok, ["UdOnTkNoW", "Arcadia"]}
      iex> Bouncer.Adapters.Redis.delete []
      {:error, "Keys '[]' not found"}
  """
  def delete(keys) when is_list(keys) do
    case RedixPool.command(~w(DEL) ++ keys) do
      {:ok, 0} -> {:error, "Keys '#{keys}' not found"}
      _ -> {:ok, keys}
    end
  end

  @doc """
  Deletes a given key from Redis.

  ## Examples
      iex> Bouncer.Adapters.Redis.save %{id: 1}, "UdOnTkNoW", nil
      ...> Bouncer.Adapters.Redis.delete "UdOnTkNoW"
      {:ok, "UdOnTkNoW"}
      iex> Bouncer.Adapters.Redis.delete "Arcadia"
      {:error, "Key 'Arcadia' not found"}
  """
  def delete(key) do
    case RedixPool.command(~w(DEL) ++ [key]) do
      {:ok, 0} -> {:error, "Key '#{key}' not found"}
      _ -> {:ok, key}
    end
  end
end
