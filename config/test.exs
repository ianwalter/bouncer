use Mix.Config

config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: Bouncer.MockRedis
