defmodule Bouncer.MockRedis do
  def command(word_list) do
    case word_list do
      ["SET", nil, _] -> {:error, "wrong number of arguments"}
      ["SET", _, nil] -> {:error, "wrong number of arguments"}
      ["SET", _, _] -> {:ok, "OK"}
      ["EXPIRE", 1, _] -> {:ok, 1}
      ["EXPIRE", 2, _] -> {:ok, 0}
      ["SADD", nil, _] -> {:error, "wrong number of arguments"}
      ["SADD", _, nil] -> {:error, "wrong number of arguments"}
      ["SADD", _, _,] -> {:ok, 1}
      ["SMEMBERS", 1] -> {:ok, ["UdOnTkNoW"]}
      ["SMEMBERS", 2] -> {:ok, []}
      ["SMEMBERS", nil] -> {:error, "wrong number of arguments"}
      ["GET", nil] -> {:error, "wrong number of arguments"}
      ["GET", "UdOnTkNoW"] -> {:ok, ~s({"id": 1})}
      ["GET", "test"] -> {:error, nil}
      ["DEL", nil] -> {:error, "wrong number of arguments"}
      ["DEL", 2] -> {:ok, 0}
      ["DEL", key] -> {:ok, 1}
    end
  end
end
