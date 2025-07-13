defmodule Tradewinds.CompaniesTest do
  use Tradewinds.DataCase, async: true

  alias Tradewinds.Companies
  alias Tradewinds.Factory

  describe "companies" do
    test "create_company/5 creates a company" do
      player = Factory.insert(:player)
      port = Factory.insert(:port)

      assert {:ok, company} =
               Companies.create_company("Test Company", "TC", 10_000, port.id, [player])

      assert company.name == "Test Company"
      assert company.ticker == "TC"
      assert company.treasury == 10_000
      assert company.home_port_id == port.id
    end

    test "credit_treasury/2 increases treasury" do
      company = Factory.insert(:company)
      assert {:ok, updated_company} = Companies.credit_treasury(company, 1000)
      assert updated_company.treasury == company.treasury + 1000
    end

    test "debit_treasury/2 decreases treasury" do
      company = Factory.insert(:company, treasury: 2000)
      assert {:ok, updated_company} = Companies.debit_treasury(company, 1000)
      assert updated_company.treasury == company.treasury - 1000
    end

    test "check_sufficient_funds/2 returns :ok for sufficient funds" do
      company = Factory.insert(:company, treasury: 2000)
      assert :ok = Companies.check_sufficient_funds(company, 1000)
    end

    test "check_sufficient_funds/2 returns error for insufficient funds" do
      company = Factory.insert(:company, treasury: 500)
      assert {:error, :insufficient_funds} = Companies.check_sufficient_funds(company, 1000)
    end
  end

  describe "presence in port" do
    test "check_presence_in_port/2 returns :ok if headquarters" do
      company = Factory.insert(:company)
      port = Repo.get!(Tradewinds.World.Port, company.home_port_id)
      assert :ok = Companies.check_presence_in_port(company, port)
    end

    test "check_presence_in_port/2 returns :ok if office is present" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      Factory.insert(:office, company: company, port: port)
      assert :ok = Companies.check_presence_in_port(company, port)
    end

    test "check_presence_in_port/2 returns :ok if ship is present" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      Factory.insert(:ship, company: company, port: port)
      assert :ok = Companies.check_presence_in_port(company, port)
    end

    test "check_presence_in_port/2 returns :ok if agent is present" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      Factory.insert(:company_agent, company: company, port: port)
      assert :ok = Companies.check_presence_in_port(company, port)
    end

    test "check_presence_in_port/2 returns error if no presence" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      assert {:error, :no_presence_in_port} = Companies.check_presence_in_port(company, port)
    end
  end

  describe "agents" do
    test "hire_agent/1 hires an agent" do
      company = Factory.insert(:company)
      assert {:ok, agent} = Companies.hire_agent(company)
      assert agent.company_id == company.id
    end

    test "hire_agent/1 returns error if max agents reached" do
      company = Factory.insert(:company)
      Factory.insert_list(3, :company_agent, company: company)
      assert {:error, :max_agents_reached} = Companies.hire_agent(company)
    end

    test "fire_agent/1 fires an agent" do
      agent = Factory.insert(:company_agent)
      assert {:ok, _} = Companies.fire_agent(agent)
      assert nil == Repo.get(Tradewinds.Companies.CompanyAgent, agent.id)
    end
  end

  describe "fetching resources" do
    test "fetch_ship/2 returns a ship" do
      company = Factory.insert(:company)
      ship = Factory.insert(:ship, company: company)
      assert {:ok, fetched_ship} = Companies.fetch_ship(company, ship.id)
      assert fetched_ship.id == ship.id
    end

    test "fetch_warehouse/2 returns a warehouse" do
      company = Factory.insert(:company)
      warehouse = Factory.insert(:warehouse, company: company)
      assert {:ok, fetched_warehouse} = Companies.fetch_warehouse(company, warehouse.id)
      assert fetched_warehouse.id == warehouse.id
    end

    test "fetch_ship_inventories_in_port/3" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      item = Factory.insert(:item)
      ship = Factory.insert(:ship, company: company, port: port)
      Factory.insert(:ship_inventory, ship: ship, item: item, amount: 100)

      results = Companies.fetch_ship_inventories_in_port(company, port, item)
      assert [%{type: :ship, id: fetched_ship_id, amount: 100}] = results
      assert fetched_ship_id == ship.id
    end

    test "fetch_warehouse_inventories_in_port/3" do
      company = Factory.insert(:company)
      port = Factory.insert(:port)
      item = Factory.insert(:item)
      warehouse = Factory.insert(:warehouse, company: company, port: port)
      Factory.insert(:warehouse_inventory, warehouse: warehouse, item: item, amount: 200)

      results = Companies.fetch_warehouse_inventories_in_port(company, port, item)
      assert [%{type: :warehouse, id: fetched_warehouse_id, amount: 200}] = results
      assert fetched_warehouse_id == warehouse.id
    end
  end
end
