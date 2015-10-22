defmodule Bouncer.PasswordReset do
  @moduledoc """
  A library of functions used to help with resetting user passwords.
  """

  alias Bouncer.Token

  @doc """
  Generates a password reset token. See Bouncer.Token.Generate/4.
  """
  def generate(conn, id, ttl \\ 86400) do
    Token.generate(conn, "password", id, ttl)
  end

  @doc """
  Verifies a password reset token is valid and matches the given user. See
  Bouncer.Token.Verify/4.
  """
  def verify(conn, user, token), do: Token.verify(conn, user, "password", token)

  @doc """
  Removes any previous password reset tokens and generates a new one. See
  Bouncer.Token.regenerate/4.
  """
  def regenerate(conn, user, ttl \\ 86400) do
     Token.regenerate(conn, user, "password", ttl)
  end
end
