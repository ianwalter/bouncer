defmodule Adapters.RedisTest do
  use ExUnit.Case
  
  alias Bouncer.RedixPool

  setup do
    on_exit fn -> RedixPool.command(~w(FLUSHALL)) end
  end

  doctest Bouncer.Adapters.Redis
end
