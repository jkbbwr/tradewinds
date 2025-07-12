defmodule AliasHack do
  defmacro __using__(_) do
    modules =
      :application.get_key(:tradewinds, :modules)
      |> elem(1)
      |> Enum.map(&Module.split/1)
      |> Enum.filter(fn
        ["Tradewinds", "Repo" | _] ->
          true

        ["Tradewinds", "Schema" | _] ->
          true

        _ ->
          false
      end)
      |> Enum.map(&Module.safe_concat/1)

    for module <- modules do
      quote do
        alias unquote(module)
      end
    end
  end
end

use AliasHack

alias Tradewinds.Repo
import Ecto.Query

player = Repo.get_by!(Player, name: "kibb")
company = Repo.get_by!(Company, ticker: "EIC")
london = Repo.get_by!(Port, name: "London")
warehouse = Repo.get_by!(Warehouse, company_id: company.id)
beer = Repo.get_by!(Item, name: "Beer")
