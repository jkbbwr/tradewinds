defmodule Tradewinds.Trading do
  @moduledoc """
  The Trading context.
  Encapsulates the primary game loop of trade, managing ships, cargo, and markets.
  """

  def buy(player, company, port, trader, item, amount) do
    with :ok <- Tradewinds.Companies.check_presence_in_port(company, port.id),
         :ok <- check_trader_location(trader, port) do
      # TODO: Implement the rest of the buy logic
      {:error, :not_implemented}
    else
      error -> error
    end
  end

  defp check_trader_location(trader, port) do
    if trader.port_id == port.id do
      :ok
    else
      {:error, :trader_not_in_port}
    end
  end

  def calculate_spot_price(trader, item) do
  end
end
