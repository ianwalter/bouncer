use Mix.Config

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://localhost:6379/2",
  pool_size: 1
