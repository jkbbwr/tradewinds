defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Companies
  alias Tradewinds.Schema.Office

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

  describe "offices" do
    test "open_office/2 creates an office for a company" do
      company = insert(:company)
      port = insert(:port)

      {:ok, office} = Companies.open_office(company, port)

      assert office.company_id == company.id
      assert office.port_id == port.id
    end

    test "close_office/2 deletes an office for a company" do
      company = insert(:company)
      port = insert(:port)
      insert(:office, company: company, port: port)

      {:ok, _office} = Companies.close_office(company, port)

      assert Repo.get_by(Office, company_id: company.id, port_id: port.id) == nil
    end

    test "returns an error when opening a fourth office" do
      company = insert(:company)
      ports = insert_list(3, :port)
      for port <- ports do
        {:ok, _} = Companies.open_office(company, port)
      end

      port = insert(:port)

      {:error, changeset} = Companies.open_office(company, port)

      assert !changeset.valid?
      assert changeset.errors[:company_id] == {"can't have more than 3 offices", []}
    end
  end

  describe "treasury" do
    test "debit_treasury/2 deducts from the treasury" do
      company = insert(:company, treasury: 1000)

      {:ok, updated_company} = Companies.debit_treasury(company, 500)

      assert updated_company.treasury == 500
    end
  end
end
