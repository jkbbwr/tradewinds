defmodule Tradewinds.Discord.Commands.Toggle do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description() do
    "Toggles a player."
  end

  @impl true
  def command(interaction) do
    [%{name: "toggle", value: toggle}, %{name: "email", value: email}] = interaction.data.options

    toggle_function =
      case toggle do
        "enable" -> &Tradewinds.Accounts.enable/1
        "disable" -> &Tradewinds.Accounts.disable/1
      end

    with {:ok, player} <- Tradewinds.Accounts.fetch_player_by_email(email),
         {:ok, updated} <- toggle_function.(player) do
      [
        content: "Success! - ```elixir\n#{inspect(updated, pretty: true)}```",
        ephemeral?: true
      ]
    else
      {:error, err} ->
        [content: "Failed! - #{inspect(err)}", ephemeral?: true]
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
        name: "toggle",
        description: "Enable or disable.",
        required: true,
        choices: [
          %{
            name: "Enable",
            # A role ID, passed to your `command/1` callback via the Interaction struct.
            value: "enable"
          },
          %{
            name: "Disable",
            value: "disable"
          }
        ]
      },
      %{
        type: :string,
        name: "email",
        description: "Email of the player to enable",
        required: true
      }
    ]
  end
end
