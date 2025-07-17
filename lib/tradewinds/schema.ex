defmodule Tradewinds.Schema do
  @moduledoc """
  Provides common schema configuration for the application.
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset

      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @timestamps_opts [type: :utc_datetime]
      @foreign_key_type Ecto.UUID
    end
  end
end
