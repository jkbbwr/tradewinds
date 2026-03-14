defmodule Tradewinds.Discord.Commands.Bailout do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Bailout a company"
  end

  @impl true
  def command(interaction) do
    case interaction.data.options do
      [%{name: "ticker", value: ticker}] ->
        ticker = String.upcase(ticker)

        case Tradewinds.Companies.fetch_company_by_ticker(ticker) do
          {:ok, company} ->
            amount = Tradewinds.Companies.calculate_bailout(company.id)

            case Tradewinds.Companies.bailout(company.id, amount) do
              {:ok, _updated_company} ->
                [
                  content:
                    "Success! Company #{company.name} (#{company.ticker}) has been bailed out for #{amount} credits."
                ]

              {:error, err} ->
                [content: "Failed to apply bailout: #{inspect(err)}", ephemeral?: true]
            end

          {:error, err} ->
            [content: "Failed to lookup company by ticker: #{inspect(err)}", ephemeral?: true]
        end

      _ ->
        [content: "Invalid arguments provided.", ephemeral?: true]
    end
  end

  @impl true
  def type() do
    :slash
  end

  @impl true
  def options() do
    [
      %{
        type: :string,
        name: "ticker",
        description: "Ticker of the company to bailout",
        required: true
      }
    ]
  end
end
