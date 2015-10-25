defmodule Bouncer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # NOTE: If a new adapter is added, logic will have to be added here
    children = [
      supervisor(Bouncer.RedixPool, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bouncer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
