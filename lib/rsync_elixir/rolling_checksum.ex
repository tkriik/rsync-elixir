defmodule RsyncElixir.RollingChecksum do
  use Bitwise, only: [&&&: 2]

  @modulus 0xFFFF

  @type checksum :: 0..0xFFFFFFFF

  @type context :: {
          k :: non_neg_integer,
          l :: non_neg_integer,
          x0 :: byte,
          a :: checksum,
          b :: checksum
        }

  @spec init(data :: binary) :: context
  def init(<<>>) do
    {0, 0, 0, 0, 0}
  end

  def init(data) do
    k = 0
    l = byte_size(data)
    x0 = :binary.at(data, l - 1)
    a = init_a(data)
    b = init_b(data, l)
    {k, l, x0, a, b}
  end

  @spec update(context, x1 :: byte) :: context
  def update({k, l, x0, a0, b0}, x1) do
    a1 = update_a(a0, x0, x1)
    b1 = update_b(b0, k, l, a1, x0)
    {k + 1, l + 1, x1, a1, b1}
  end

  @spec final(context) :: checksum
  def final({_, _, _, a, b}) do
    a + 0xFFFF * b
  end

  @spec compute(data :: binary) :: checksum
  def compute(data) do
    final(init(data))
  end

  @spec size() :: 4
  def size() do
    4
  end

  defp init_a(data) do
    init_a(data, 0)
  end

  defp init_a(<<>>, checksum) do
    checksum &&& @modulus
  end

  defp init_a(<<x, xs::binary>>, checksum) do
    init_a(xs, checksum + x)
  end

  defp init_b(data, k) do
    init_b(data, 0, k, 0)
  end

  defp init_b(<<>>, _, _, checksum) do
    checksum &&& @modulus
  end

  defp init_b(<<x, xs::binary>>, i, k, checksum) do
    checksum = checksum + x * (k - i + 1)
    init_b(xs, i + 1, k, checksum)
  end

  # TODO: benchmark with and without inline
  @compile {:inline, update_a: 3}
  defp update_a(a0, x0, x1) do
    a0 - x0 + x1 &&& @modulus
  end

  # TODO: benchmark with and without inline
  @compile {:inline, update_b: 5}
  defp update_b(b0, k, l, a1, x0) do
    b0 - (l - k + 1) * x0 + a1 &&& @modulus
  end
end
