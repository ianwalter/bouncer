use Mix.Config

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://localhost:6379/2"
