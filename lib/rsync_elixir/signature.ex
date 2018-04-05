defmodule RsyncElixir.Signature do
  alias RsyncElixir.MD5
  alias RsyncElixir.RollingChecksum

  @spec generate(input_dev :: pid, signature_dev :: pid, block_size :: non_neg_integer) ::
          :ok | {:error, :read | :write, term()}
  def generate(input_dev, signature_dev, block_size) do
    case IO.binread(input_dev, block_size) do
      :eof ->
        :ok

      {:error, reason} ->
        {:error, :read, reason}

      data ->
        checksum = RollingChecksum.compute(data)
        hash = MD5.hash(data)

        case IO.binwrite(signature_dev, [<<checksum::size(32)>>, hash]) do
          :ok -> generate(input_dev, signature_dev, block_size)
          {:error, reason} -> {:error, :write, reason}
        end
    end
  end

  @spec size() :: 20
  def size() do
    MD5.size() + RollingChecksum.size()
  end
end
