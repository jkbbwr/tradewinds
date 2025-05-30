defmodule TradewindsWeb.ErrorJSON do
  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  def error(%{changeset: changeset}) do
    %{errors: Ecto.Changeset.traverse_errors(changeset, &translate_error/1)}
  end

  def render("404.json", _error) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("500.json", _error) do
    %{errors: %{detail: "Internal Server Error"}}
  end
end
