defmodule TradewindsWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, %{message: message}) do
    %{errors: %{detail: message, status: translate_status(template)}}
  end

  def render(template, _assigns) do
    %{errors: %{detail: translate_status(template)}}
  end

  defp translate_status(status) when is_atom(status) do
    status
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp translate_status(template) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
