# Bouncer (alpha, not used in production yet)

**Token-based authorization and session management for Phoenix (Elixir)**

[![Build Status](https://semaphoreci.com/api/v1/projects/f9fd62d2-a799-4b66-8d72-06bbc290d32b/570486/shields_badge.svg)](https://semaphoreci.com/ianwalter/bouncer)

## Why

I needed a way to authorize API requests to my Phoenix application.
[Addict](https://github.com/trenpixster/addict) didn't fit the bill since it
uses Phoenix's built-in session system. Phoenix uses cookies to authorize
requests but when dealing with an API, it's easier to deal with an Authorization
header. Phoenix's session system also uses memory or ETS to store session data
and this wouldn't work for my application which would be scaled horizontally and
so would be running on multiple machines. Redis is great at solving this problem
because it's crazy-fast and can be accessed by multiple machines. The ecosystem
around Redis is strong so working with the session data is pretty easy.

[Guardian](https://github.com/hassox/guardian) also wouldn’t work because it
uses JSON Web Tokens (JWT) as the basis for it’s authorization scheme. JWTs can
work but [I don’t believe it’s a better system than the traditional session-based system](https://medium.com/@IanWalter/ole-thank-you-for-your-response-it-s-exactly-the-kind-of-feedback-i-was-looking-for-117df9438ccc#.icimd0nwv). JWTs don't provide a way of immediately invalidating
user sessions instead relying on short token lifetimes. The ability to
immediately invalidate a session is a feature that I want to provide to users
as well as be able to do on occasion (i.e. when a user resets their password).

## Features

* Creating a session returns a token that can be used in the authorization
  header of each API request.
* Backed by Redis so it's able to be used in a multi-server or multi-container
  environment without configuring sticky sessions. Also, Redis is pretty fast.
* Simple API to create, update, and destroy session data.
* Simple API to generate, verify, and regenerate email verification or password
  reset tokens.

## Installation

Bouncer is [available in Hex](https://hex.pm/packages/bouncer), the package can
be installed as:

  1. Add bouncer to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:bouncer, "~> 0.1.3"}]
    end
    ```

  2. Ensure bouncer is started before your application:

    ```elixir
    def application do
      [applications: [:bouncer]]
    end
    ```

## Requirements & Configuration

Bouncer requires the [Phoenix framework](http://www.phoenixframework.org/)
because it uses it's Token module to generate tokens that are used both as an
Authorization header and a session key. Despite this requirement, I imagine it
could be used with an [Plug](https://github.com/elixir-lang/plug)-based
framework. Bouncer provides a plug that can be used to authorize a request for
certain controllers and/or controller actions:

```elixir
# This would be added near the top of a UserController for example
plug Bouncer.Plugs.Authorize when action in [:show, :update, :delete]
```

Bouncer only has one session store adapter so far: [Redis](http://redis.io/).
Bouncer uses the fantastic [Redix](https://github.com/whatyouhide/redix) library
to interface with Redis and we've added a module called Bouncer.RedixPool that
will pool connections to Redis. Here's what you would put in your environment's
configuration file:

```elixir
# config/dev.exs
config :bouncer,
  adapter: Bouncer.Adapters.Redis,
  redis: "redis://somehost:6379/1"
```

The second configuration option, `redis`, is not necessary if your Redis
instance is on localhost and using the default port. You might want to specify
a different database (i.e. `redis://localhost:6379/2`) in your test
configuration file.

## Documentation

The source is really small so reading through it should be straight-forward but
the full package documentation is available at https://hexdocs.pm/bouncer.

## Example of a SessionController

Here's and example of how you can use the
[Bouncer.Session](http://hexdocs.pm/bouncer/Bouncer.Session.html) API in
your application:

```elixir
# web/controllers/session_controller.ex
defmodule MyApp.SessionController do
  use MyApp.Web, :controller

  alias MyApp.User
  alias MyApp.UserView
  alias Bouncer.Session
  alias Comeonin.Bcrypt

  plug Bouncer.Plugs.Authorize when action in [:delete]

  def create(conn, %{"user" => user_params}) do
    case Repo.get_by(User, %{username: user_params["username"]}) do
      nil ->
        Bcrypt.dummy_checkpw()
        send_resp(conn, :bad_request, "")

      user ->
        if Bcrypt.checkpw(user_params["password"], user.encrypted_password) do
          user_map = User.to_map(user, true)
          {_, token} = Session.generate(conn, user_map)

          conn
          |> put_status(:created)
          |> render(UserView, "create.json", %{user: user_map, token: token})
        else
          send_resp(conn, :bad_request, "")
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    if Session.user_request? conn, id do
      case Session.destroy(conn.private.auth_token) do
        {:ok, _} -> send_resp(conn, :no_content, "")
        _ -> send_resp(conn, :bad_request, "")
      end
    else
      conn
      |> put_status(:unauthorized)
      |> render(ErrorView, "error.json")
    end
  end
end
```
