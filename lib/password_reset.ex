defmodule Bouncer.PasswordReset do
  @moduledoc """
  A library of functions used to help with resetting user passwords.
  """

  alias Bouncer.Token

  @doc """
  """
  def generate(conn, id, ttl \\ 86400) do
    Token.generate(conn, "password", id, ttl)
  end

  @doc """
  """
  def verify(conn, id, token), do: Token.verify(conn, id, "password", token)

  @doc """
  """
  def regenerate(conn, id, ttl \\ 86400) do
     Token.regenerate(conn, id, "password", ttl)
  end
end
