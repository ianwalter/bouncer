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
  Verifies that a email verification token is valid. Returns associated data
  from the store using the token as a key. See Bouncer.Token.Verify/3.
  """
  def verify(conn, token), do: Token.verify(conn, "email", token)

  @doc """
  Removes any previous email verification tokens and generates a new one. See
  Bouncer.Token.regenerate/4.
  """
  def regenerate(conn, user, ttl \\ 86400) do
     Token.regenerate(conn, "email", user, ttl)
  end

  @doc """
  Destroys a email verification token given the token and user ID. See
  Bouncer.Token.delete/2.
  """
  def destroy(token, id), do: Token.delete(token, id)
end
