defmodule Tradewinds.Discord.Safe do
  def escape_unescaped_backticks(s) when is_binary(s) do
    Regex.replace(~r/(?<!\\)`/, s, "\\`")
  end
end
