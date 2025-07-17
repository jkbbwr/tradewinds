defmodule TradewindsWeb.ErrorJSON do
  @moduledoc """
  Renders errors as JSON.
  """

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  @doc """
  Renders changeset errors.
  """
  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  @doc """
  Renders a 404 Not Found error.
  """
  def render("404.json", _error) do
    %{errors: %{detail: "Not Found"}}
  end

  @doc """
  Renders a 500 Internal Server Error.
  """
  def render("500.json", _error) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
