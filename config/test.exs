use Mix.Config

config :logger, level: :debug

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://redis:6379/2",
  pool_size: 1,
  pool_overflow: 0
