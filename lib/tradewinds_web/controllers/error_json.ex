defmodule TradewindsWeb.ErrorJSON do
  defp humanize_reason(atom) when is_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.downcase()
    |> String.capitalize()
  end

  def render("400.json", _assigns) do
    %{errors: %{detail: "Bad Request"}}
  end

  def render("404.json", %{}) do
    %{errors: %{detail: "Not Found"}}
  end

  def render("406.json", _assigns) do
    %{errors: %{detail: "Not Acceptable"}}
  end

  def render("not_found.json", %{reason: reason, id: id}) do
    %{errors: %{detail: humanize_reason(reason), id: id}}
  end

  def render("not_found.json", %{}) do
    %{errors: %{detail: "Resource not found"}}
  end

  def render("unprocessable_entity.json", %{}) do
    %{errors: %{detail: "Insufficient Funds"}}
  end

  def render("unauthorized.json", %{reason: reason}) do
    %{errors: %{detail: "Unauthorized: #{reason}"}}
  end

  def render("unauthorized.json", %{}) do
    %{errors: %{detail: "Unauthorized"}}
  end

  def render("account_disabled.json", %{}) do
    %{errors: %{detail: "Account is disabled"}}
  end

  def render("422.json", %{message: message}) do
    %{errors: %{detail: message}}
  end

  def render("500.json", %{}) do
    %{errors: %{detail: "Internal Server Error"}}
  end

  def error(%{status: :insufficient_funds}) do
    %{errors: %{detail: "Insufficient funds to complete this trade."}}
  end

  def error(%{changeset: changeset}) do
    # When handled by the controller, it will wrap this in a %{errors: ...} map
    # according to standard Phoenix patterns, or we can do it here.
    %{errors: Goal.traverse_errors(changeset, &translate_error/1)}
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
