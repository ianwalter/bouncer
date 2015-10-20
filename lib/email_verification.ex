defmodule Bouncer.EmailVerification do
  @moduledoc """
  A library of functions used to work with email verification.
  """

  alias Elector.Token

  def generate(conn, id, ttl // default: 86400) do
    Token.generate(conn, "email", id, ttl)
  end

  def verify(conn, id, token), do: Token.verify(conn, id, "email", token)

  def regenerate(conn, id, ttl), do: Token.regenerate(conn, id, ttl)
end
