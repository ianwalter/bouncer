defmodule Bouncer.MockRedis do
  def command(word_list) do
    case word_list do
      ["SET", nil, _] -> {:error, "wrong number of arguments"}
      ["SET", _, nil] -> {:error, "wrong number of arguments"}
      ["SET", _, _] -> {:ok, "OK"}
      ["GET", nil] -> {:error, "wrong number of arguments"}
      ["GET", "UdOnTkNoW"] -> {:ok, ~s({"id": 1})}
      ["GET", "test"] -> {:error, nil}
      ["DEL", nil] -> {:error, "wrong number of arguments"}
      ["DEL", 2] -> {:ok, 0}
      ["DEL", key] -> {:ok, 1}
    end
  end
end
