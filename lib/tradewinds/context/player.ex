defmodule Tradewinds.Player do
  defdelegate register(name, email, password), to: Tradewinds.Repo.PlayerRepo
end
