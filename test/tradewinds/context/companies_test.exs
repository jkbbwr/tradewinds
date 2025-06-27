defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase, async: true

  import Tradewinds.Factory

  alias Tradewinds.Companies
  alias Tradewinds.Schema.Company
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

      assert Repo.fetch_by(Office, company_id: company.id, port_id: port.id) ==
               {:error, :not_found}
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

  describe "presence" do
    test "check_presence_in_port/2 returns :ok if port is headquarters" do
      port = insert(:port)
      company = insert(:company, home_port_id: port.id)

      assert Companies.check_presence_in_port(company, port.id) == :ok
    end

    test "check_presence_in_port/2 returns :ok if company has an office in the port" do
      port = insert(:port)
      company = insert(:company)
      insert(:office, company: company, port: port)

      assert Companies.check_presence_in_port(company, port.id) == :ok
    end

    test "check_presence_in_port/2 returns :ok if company has a ship in the port" do
      port = insert(:port)
      company = insert(:company)
      insert(:ship, company: company, port: port)

      assert Companies.check_presence_in_port(company, port.id) == :ok
    end

    test "check_presence_in_port/2 returns an error if company has no presence" do
      port = insert(:port)
      company = insert(:company)

      assert Companies.check_presence_in_port(company, port.id) == {:error, :no_presence_in_port}
    end
  end

  describe "warehouses" do
    test "adjust_warehouse_capacity/3 creates a warehouse if one does not exist" do
      port = insert(:port, warehouse_cost: 10)
      company = insert(:company, treasury: 1000, home_port_id: port.id)

      {:ok, warehouse} = Companies.adjust_warehouse_capacity(company, port, 50)

      assert warehouse.capacity == 50
      updated_company = Repo.get(Company, company.id)
      assert updated_company.treasury == 500
    end

    test "adjust_warehouse_capacity/3 increases capacity of an existing warehouse" do
      port = insert(:port, warehouse_cost: 10)
      company = insert(:company, treasury: 1000, home_port_id: port.id)
      insert(:warehouse, company: company, port: port, capacity: 20)

      {:ok, warehouse} = Companies.adjust_warehouse_capacity(company, port, 50)

      assert warehouse.capacity == 50
      updated_company = Repo.get(Company, company.id)
      assert updated_company.treasury == 700
    end

    test "adjust_warehouse_capacity/3 shrinks capacity of an existing warehouse" do
      port = insert(:port, warehouse_cost: 10)
      company = insert(:company, treasury: 1000, home_port_id: port.id)
      insert(:warehouse, company: company, port: port, capacity: 50)

      {:ok, warehouse} = Companies.adjust_warehouse_capacity(company, port, 20)

      assert warehouse.capacity == 20
      updated_company = Repo.get(Company, company.id)
      assert updated_company.treasury == 1000
    end

    test "adjust_warehouse_capacity/3 returns an error for insufficient funds" do
      port = insert(:port, warehouse_cost: 10)
      company = insert(:company, treasury: 100, home_port_id: port.id)

      assert Companies.adjust_warehouse_capacity(company, port, 50) ==
               {:error, :insufficient_funds}
    end

    test "adjust_warehouse_capacity/3 returns an error if company has no presence" do
      port = insert(:port)
      company = insert(:company)

      assert Companies.adjust_warehouse_capacity(company, port, 50) ==
               {:error, :no_presence_in_port}
    end
  end

  describe "treasury" do
    test "debit_treasury/2 deducts from the treasury" do
      company = insert(:company, treasury: 1000)

      {:ok, updated_company} = Companies.debit_treasury(company, 500)

      assert updated_company.treasury == 500
    end

    test "check_sufficient_funds/2 returns :ok if funds are sufficient" do
      company = insert(:company, treasury: 1000)

      assert Companies.check_sufficient_funds(company, 500) == :ok
    end

    test "check_sufficient_funds/2 returns an error if funds are insufficient" do
      company = insert(:company, treasury: 1000)

      assert Companies.check_sufficient_funds(company, 1500) == {:error, :insufficient_funds}
    end
  end
end
