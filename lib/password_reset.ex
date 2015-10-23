defmodule Bouncer.PasswordReset do
  @moduledoc """
  A library of functions used to help with resetting user passwords.
  """

  alias Bouncer.Token

  @doc """
  Generates a password reset token. See Bouncer.Token.Generate/4.
  """
  def generate(conn, user, ttl \\ 86400) do
    Token.generate(conn, "password", user, ttl)
  end

  @doc """
  Verifies a password reset token is valid and matches the given user ID. See
  Bouncer.Token.Verify/3.
  """
  def verify(conn, token), do: Token.verify(conn, "password", token)

  @doc """
  Removes any previous password reset tokens and generates a new one. See
  Bouncer.Token.regenerate/4.
  """
  def regenerate(conn, user, ttl \\ 86400) do
     Token.regenerate(conn, "password", user, ttl)
  end
end
