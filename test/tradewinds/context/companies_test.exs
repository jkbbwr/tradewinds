defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Companies

  describe "create_company/5" do
    test "creates a company with valid data" do
      player = insert(:user)
      port = insert(:port)

      {:ok, company} =
        Companies.create_company(
          "Test Company",
          "TEST",
          1_000_000,
          port.id,
          [player]
        )

      assert company.name == "Test Company"
      assert company.ticker == "TEST"
      assert company.treasury == 1_000_000
      assert company.home_port_id == port.id
    end

    test "returns an error when there are no directors" do
      port = insert(:port)

      {:error, changeset} =
        Companies.create_company(
          "Test Company",
          "TEST",
          1_000_000,
          port.id,
          []
        )

      assert !changeset.valid?
      assert changeset.errors[:directors] ==
             {"must have at least one director",
              [count: 1, validation: :length, kind: :min, type: :list]}
    end
  end
end
