defmodule RsyncElixir.MD5 do
  @spec hash(data :: binary) :: binary
  def hash(data) do
    :crypto.hash(:md5, data)
  end
end
