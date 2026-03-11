defmodule TradewindsWeb.ErrorJSON do
  def render("404.json", %{}) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("unauthorized.json", %{}) do
    %{errors: %{detail: "Unauthorized"}}
  end

  def render("account_disabled.json", %{}) do
    %{errors: %{detail: "Account is disabled"}}
  end

  def render("500.json", %{}) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  def error(%{changeset: changeset}) do
    # When handled by the controller, it will wrap this in a %{errors: ...} map
    # according to standard Phoenix patterns, or we can do it here.
    %{errors: Goal.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end
end
