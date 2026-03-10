import os
import time
import httpx
import uuid
import sys
import subprocess

API_URL = "http://localhost:4000/api/v1"

def run_mix_command(command):
    subprocess.run(
        f"mix run -e '{command}'",
        cwd="..",
        shell=True,
        check=True,
        stdout=subprocess.DEVNULL, # Suppress standard output to keep test logs clean
        stderr=subprocess.PIPE
    )

def run_test():
    client = httpx.Client(base_url=API_URL, timeout=30.0)

    # 1. Register & Enable Player
    email = f"test_{uuid.uuid4().hex[:8]}@example.com"
    password = "Password123!"
    
    print(f"Registering {email}...")
    res = client.post("/auth/register", json={"email": email, "name": "E2E Tester", "password": password})
    assert res.status_code == 201, f"Register failed: {res.text}"
    
    print("Enabling user via Mix...")
    run_mix_command(f'{{:ok, p}} = Tradewinds.Accounts.fetch_player_by_email("{email}"); Tradewinds.Accounts.enable(p)')
    
    # 2. Login
    print("Logging in...")
    res = client.post("/auth/login", json={"email": email, "password": password})
    assert res.status_code == 200, f"Login failed: {res.text}"
    token = res.json()["data"]["token"]
    
    client.headers.update({"Authorization": f"Bearer {token}"})

    # 3. Get World Data
    print("Fetching world data...")
    routes = client.get("/world/routes").json()["data"]
    assert len(routes) > 0, "No routes found!"
    route = routes[0]
    port_a = route["from_id"]
    port_b = route["to_id"]
    
    goods = client.get("/world/goods").json()["data"]
    good = goods[0]
    good_id = good["id"]
    
    ship_types = client.get("/world/ship-types").json()["data"]
    ship_type = ship_types[0]
    ship_type_id = ship_type["id"]

    # 4. Create Company
    print("Creating company...")
    res = client.post("/companies", json={
        "name": "E2E Trading Co",
        "ticker": "E2E",
        "home_port_id": port_a
    })
    assert res.status_code == 201, f"Create company failed: {res.text}"
    company_id = res.json()["data"]["id"]
    
    client.headers.update({"tradewinds-company-id": company_id})

    # Ensure company has enough money to bypass any starting money issues in this test
    print("Funding company...")
    run_mix_command(f'Tradewinds.Companies.record_transaction("{company_id}", 1000000, :system_grant, :system, Ecto.UUID.generate(), DateTime.utc_now())')

    # 5. Buy a Ship
    print(f"Buying ship at port {port_a}...")
    res = client.post(f"/shipyards/{port_a}/purchase", json={"ship_type_id": ship_type_id})
    assert res.status_code in [200, 201], f"Ship purchase failed: {res.text}"
    ship_id = res.json()["data"]["id"]

    # 6. Buy Cargo (Immediate Trade)
    qty = 10
    print(f"Buying {qty} units of good {good_id} from NPC trader...")
    res = client.post("/trade/execute", json={
        "port_id": port_a,
        "good_id": good_id,
        "action": "buy",
        "destinations": [{"type": "ship", "id": ship_id, "quantity": qty}]
    })
    assert res.status_code == 200, f"Trade failed: {res.text}"
    
    # 7. Move Ship
    print(f"Transiting ship {ship_id} via route {route['id']} to {port_b}...")
    res = client.post(f"/ships/{ship_id}/transit", json={"route_id": route["id"]})
    assert res.status_code == 200, f"Transit failed: {res.text}"
    
    # 8. Wait for Arrival
    print("Waiting for ship to arrive (this may take a minute)...")
    while True:
        res = client.get(f"/ships/{ship_id}")
        assert res.status_code == 200
        ship_status = res.json()["data"]["status"]
        if ship_status == "docked":
            print(f"Ship arrived at {port_b}!")
            break
        print(f"Ship status: {ship_status}... sleeping 5s")
        time.sleep(5)

    # 9. Create Warehouse at Destination
    print(f"Purchasing warehouse at {port_b}...")
    res = client.post("/warehouses", json={"port_id": port_b})
    assert res.status_code == 201, f"Warehouse purchase failed: {res.text}"
    warehouse_id = res.json()["data"]["id"]

    # 10. Transfer Cargo to Warehouse
    print(f"Transferring {qty} units from ship to warehouse...")
    res = client.post(f"/ships/{ship_id}/transfer-to-warehouse", json={
        "warehouse_id": warehouse_id,
        "good_id": good_id,
        "quantity": qty
    })
    assert res.status_code == 204, f"Transfer failed: {res.text}"

    # 11. Grow Warehouse
    print(f"Upgrading warehouse {warehouse_id}...")
    res = client.post(f"/warehouses/{warehouse_id}/grow")
    assert res.status_code == 200, f"Grow warehouse failed: {res.text}"
    assert res.json()["data"]["level"] == 2

    # 12. Create Market Sell Order
    print(f"Creating market sell order for {qty} units at port {port_b}...")
    # Add reputation manually via mix just in case (needs 200 to list)
    run_mix_command(f'Tradewinds.Companies.update_reputation("{company_id}", 500)')
    
    res = client.post("/market/orders", json={
        "port_id": port_b,
        "good_id": good_id,
        "side": "sell",
        "price": 150,
        "total": qty
    })
    assert res.status_code == 201, f"Market order failed: {res.text}"

    # 13. Check Ledger
    print("Fetching company ledger...")
    res = client.get("/company/ledger")
    assert res.status_code == 200
    ledger = res.json()["data"]
    print(f"Ledger contains {len(ledger)} entries. Last 3:")
    for entry in ledger[:3]:
        print(f" - {entry['reason']}: {entry['amount']}")

    # 14. Revoke Token
    print("Revoking authentication token...")
    res = client.post("/auth/revoke")
    assert res.status_code == 204, f"Revoke token failed: {res.text}"

    print("✅ Full E2E Integration Test Passed Successfully!")

if __name__ == "__main__":
    try:
        run_test()
    except Exception as e:
        print(f"❌ Test Failed: {e}")
        sys.exit(1)
