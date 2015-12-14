use Mix.Config

config :logger, level: :info

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://localhost:6379/2",
  pool_size: 1,
  pool_overflow: 0
