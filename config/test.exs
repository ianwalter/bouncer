use Mix.Config

config :logger, level: :debug

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://localhost:6379",
  pool_size: 1,
  pool_overflow: 0
