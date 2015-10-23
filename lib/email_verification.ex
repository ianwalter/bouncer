defmodule Bouncer.EmailVerification do
  @moduledoc """
  A library of functions used to work with email verification.
  """

  alias Bouncer.Token

  @doc """
  Generates an email verification token. See Bouncer.Token.Generate/4.
  """
  def generate(conn, user, ttl \\ 86400) do
    Token.generate(conn, "email", user, ttl)
  end

  @doc """
  Verifies an email verification token is valid and matches the given user ID.
  See Bouncer.Token.Verify/4.
  """
  def verify(conn, token), do: Token.verify(conn, token, "email")

  @doc """
  Removes any previous email verification tokens and generates a new one. See
  Bouncer.Token.regenerate/4.
  """
  def regenerate(conn, user, ttl \\ 86400) do
     Token.regenerate(conn, user, "email", ttl)
  end
end
