defmodule Bouncer.MockEndpoint do
  def config(:secret_key_base) do
    ["clickclickboom"]
  end
end
