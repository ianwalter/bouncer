defmodule Adapters.RedisTest do
  use ExUnit.Case

  defmodule MockRedis do
    def command(word_list) do
      case word_list do
        ["SET", nil, _] -> { :error, "wrong number of arguments" }
        ["SET", _, nil] -> { :error, "wrong number of arguments" }
        ["SET", _, _] -> { :ok, "OK" }
        ["GET", nil] -> { :error, "wrong number of arguments" }
        ["GET", 1] -> { :ok, ~s("id": 1) }
        ["GET", 2] -> { :error, nil }
        ["DEL", nil] -> { :error, "wrong number of arguments" }
        ["DEL", 2] -> { :ok, 0 }
        ["DEL", key] -> { :ok, key }
      end
    end
  end

  Application.put_env(:bouncer, :redis, MockRedis)

  doctest Bouncer.Adapters.Redis
end
