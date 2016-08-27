defmodule Bouncer.Utility do
  @moduledoc """
  A library of functions used for debugging.
  """

  require Logger

  def debug_piped(piped, message \\ nil) do
    if Application.get_env(:logger, :level) === :debug do
      case message do
        nil -> Logger.debug piped
        _ -> Logger.debug "#{message} #{inspect piped}"
      end
    end
    piped
  end

end
