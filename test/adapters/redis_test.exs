defmodule Adapters.RedisTest do
  use ExUnit.Case

  alias Bouncer.RedixPool

  setup do
    RedixPool.command ~w(FLUSHALL)
    :ok
  end

  doctest Bouncer.Adapters.Redis
end
