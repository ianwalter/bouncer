defmodule Bouncer.MockToken do
  def verify(_, _, token) do
    case token do
      "test" -> {:error, :invalid}
      "UdOnTkNoW" -> {:ok, 1}
    end
  end

  def sign(_, _, id) do
    case id do
      1 -> "UdOnTkNoW"
    end
  end

  def keyword_list, do: [verify: &verify/3, sign: &sign/3]
end
