# Bouncer

**Token-based authentication and session management for Phoenix (Elixir)**

[![Build Status](https://semaphoreci.com/api/v1/projects/f9fd62d2-a799-4b66-8d72-06bbc290d32b/570486/shields_badge.svg)](https://semaphoreci.com/ianwalter/bouncer)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add bouncer to your list of dependencies in `mix.exs`:

        def deps do
          [{:bouncer, "~> 0.0.1"}]
        end

  2. Ensure bouncer is started before your application:

        def application do
          [applications: [:bouncer]]
        end
