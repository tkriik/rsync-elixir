defmodule RsyncElixir.SignatureTest do
  alias File.Stat
  alias RsyncElixir.Signature

  use ExUnit.Case

  test "generates signature file" do
    in_path = "test/fixtures/words"
    signature_path = "test/fixtures/words.sig"

    in_dev = File.open!(in_path, [:read, :binary])
    signature_dev = File.open!(signature_path, [:write, :binary])
    block_size = 0xFFFF

    assert Signature.generate(in_dev, signature_dev, block_size) == :ok

    %Stat{:size => in_size} = File.stat!(in_path)
    %Stat{:size => signature_size} = File.stat!(signature_path)

    assert div(in_size, block_size) + 1 == div(signature_size, Signature.size())
  end
end
