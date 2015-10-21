defmodule Bouncer.EmailVerification do
  @moduledoc """
  A library of functions used to work with email verification.
  """

  alias Bouncer.Token

  @doc """
  """
  def generate(conn, id, ttl \\ 86400) do
    Token.generate(conn, "email", id, ttl)
  end

  @doc """
  """
  def verify(conn, id, token), do: Token.verify(conn, id, "email", token)

  @doc """
  """
  def regenerate(conn, id, ttl \\ 86400) do
     Token.regenerate(conn, id, "email", ttl)
  end
end
