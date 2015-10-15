# Bouncer (alpha, not used in production yet)

**Token-based authorization and session management for Phoenix (Elixir)**

[![Build Status](https://semaphoreci.com/api/v1/projects/f9fd62d2-a799-4b66-8d72-06bbc290d32b/570486/shields_badge.svg)](https://semaphoreci.com/ianwalter/bouncer)

## Why

I needed a way to authorize API requests to my Phoenix application. Addict
didn't fit the bill since it uses Phoenix's built-in session system. Phoenix
uses cookies to authorize requests but when dealing with an API, it's easier to
deal with an Authorization header. Phoenix's session system also uses memory or
ETS to store session data and this wouldn't work for my application which would
be scaled horizontally and so would be running on multiple machines. Redis is
great at solving this problem because it's crazy-fast and can be accessed by
multiple machines. The ecosystem around Redis is strong so working with the
session data is pretty easy.

Guardian also wouldn't work because it uses JSON Web Tokens (JWT) as the basis
for it's authorization scheme. JWT can work but from my understanding, you need
a system to refresh the tokens in case your user's JWT gets into the wrong
hands. Guardian doesn't yet provide this functionality and I personally think
the whole concept is more flawed than the traditional session-based system which
allows you to immediately invalidate sessions.

## Installation

Bouncer is [available in Hex](https://hex.pm/packages/bouncer), the package can be
installed as:

  1. Add bouncer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bouncer, "~> 0.0.2"}]
    end
    ```

  2. Ensure bouncer is started before your application:

    ```elixir
    def application do
      [applications: [:bouncer]]
    end
    ```

## Requirements & Configuration

Bouncer only has one session store adapter so far: [Redis](http://redis.io/).
Add the following configuration once you have Redis set up:

```elixir
config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "Enter your Redis connection pool here"
```

Bouncer also requires the [Phoenix framework]() because it uses it's Token
module to generate tokens that are used both as an Authorization header and a
session key. Bouncer provides a Plug that can be used to authorize a request
for certain controllers and/or controller actions:

```elixir
# This would be added near the top of a UserController for example
plug Bouncer.Plugs.Authorize when action in [:show, :update, :delete]
```

## Session API

This is a summary of the Session API. Full package documentation is available at
https://hexdocs.pm/bouncer

#### Session.create(conn, user)

Creates a session for a given user and saves it to the session store. Returns
the session token which will be used as the API authorization token.

#### Session.get(conn, token)

Retrieves session data given a token (key) and assigns it to the connection.

#### Session.destroy(key)

Destroys a session by removing session data from the store.

## Example of a SessionController

Here's and example of how you can use the Session API in your application:

```elixir
# web/controllers/session_controller.ex
defmodule MyApp.SessionController do
  use MyApp.Web, :controller

  alias MyApp.User
  alias Bouncer.Session

  plug :scrub_params, "user" when action in [:create]
  plug Bouncer.Plugs.Authorize when action in [:delete]

  def create(conn, %{"user" => user_params}) do
    # TODO
  end

  def delete(conn) do
    case Session.destroy(conn.assigns.token) do
      { :ok, _ } -> send_resp(conn, :no_content, "")
      { status, response } -> send_resp(conn, :bad_request, "")
    end
  end
end
```
