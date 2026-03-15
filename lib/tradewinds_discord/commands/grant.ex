defmodule Tradewinds.Discord.Commands.Grant do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Grant money to a company"
  end

  @impl true
  def command(interaction) do
    # options can come in any order, so we find them
    ticker_opt = Enum.find(interaction.data.options, fn o -> o.name == "ticker" end)
    amount_opt = Enum.find(interaction.data.options, fn o -> o.name == "amount" end)

    if ticker_opt && amount_opt do
      ticker = String.upcase(ticker_opt.value)
      amount = amount_opt.value

      case Tradewinds.Companies.fetch_company_by_ticker(ticker) do
        {:ok, company} ->
          case Tradewinds.Companies.grant(company.id, amount) do
            {:ok, _updated_company} ->
              [
                content:
                  "Success! Company #{company.name} (#{company.ticker}) has been granted #{amount} credits."
              ]

            {:error, err} ->
              [content: "Failed to grant money: #{inspect(err)}", ephemeral?: true]
          end

        {:error, err} ->
          [content: "Failed to lookup company by ticker: #{inspect(err)}", ephemeral?: true]
      end
    else
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
        description: "Ticker of the company to grant money to",
        required: true
      },
      %{
        type: :integer,
        name: "amount",
        description: "Amount of money to grant",
        required: true
      }
    ]
  end
end
