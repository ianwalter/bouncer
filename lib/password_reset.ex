defmodule Bouncer.PasswordReset do
  @moduledoc """
  A library of functions used to help with resetting user passwords.
  """

  alias Phoenix.Token

  def generate(conn, id) do
    case Token.sign(conn, "user", id) do

    end

    # Generate token based on user ID
    # Save token to user hash under "email_verification_token"
    # Return token

  end

  def verify(conn, id, token) do
    # Get all from user hash
    # Verify
  end

  def regenerate(user) do

  end
end
