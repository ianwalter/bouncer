defmodule Bouncer.EmailVerification do
  @moduledoc """
  A library of functions used to work with email verification.
  """

  alias Bouncer.Token

  @doc """
  Generates an email verification token. See Bouncer.Token.Generate/4.
  """
  def generate(conn, id, ttl \\ 86400) do
    Token.generate(conn, "email", id, ttl)
  end

  @doc """
  Verifies an email verification token is valid and matches the given user. See
  Bouncer.Token.Verify/4.
  """
  def verify(conn, id, token), do: Token.verify(conn, id, "email", token)

  @doc """
  Removes any previous email verification tokens and generates a new one. See
  Bouncer.Token.regenerate/4.
  """
  def regenerate(conn, id, ttl \\ 86400) do
     Token.regenerate(conn, id, "email", ttl)
  end
end
