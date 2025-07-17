import json
import random

def generate_trader_plans(traders, ports, items, exports):
    plans = []
    for port_name, item_names in exports.items():
        port = next((p for p in ports if p['name'] == port_name), None)
        if not port:
            continue

        trader = next((t for t in traders if t['port_id'] == port['id']), None)
        if not trader:
            continue

        for item_name in item_names:
            item = next((i for i in items if i['name'] == item_name), None)
            if not item:
                continue

            plan = {
                "trader_id": trader['id'],
                "item_id": item['id'],
                "average_acquisition_cost": random.randint(50, 150),
                "ideal_stock_level": random.randint(100, 500),
                "target_profit_margin": round(random.uniform(0.1, 0.5), 2),
                "max_buy_sell_spread": round(random.uniform(0.2, 0.6), 2),
                "price_elasticity": round(random.uniform(0.8, 1.2), 2),
                "liquidity_factor": round(random.uniform(0.3, 0.7), 2),
                "consumption_rate": random.randint(10, 50),
                "reversion_rate": round(random.uniform(0.05, 0.2), 2),
                "regional_cost": random.randint(80, 120),
            }
            plans.append(plan)
    return plans

def generate_sql_inserts(plans):
    inserts = []
    for plan in plans:
        inserts.append(
            f"INSERT INTO trader_plan (id, trader_id, item_id, average_acquisition_cost, ideal_stock_level, target_profit_margin, max_buy_sell_spread, price_elasticity, liquidity_factor, consumption_rate, reversion_rate, regional_cost, inserted_at, updated_at) VALUES (gen_random_uuid(), '{plan['trader_id']}', '{plan['item_id']}', {plan['average_acquisition_cost']}, {plan['ideal_stock_level']}, {plan['target_profit_margin']}, {plan['max_buy_sell_spread']}, {plan['price_elasticity']}, {plan['liquidity_factor']}, {plan['consumption_rate']}, {plan['reversion_rate']}, {plan['regional_cost']}, NOW(), NOW());"
        )
    return inserts

if __name__ == '__main__':
    with open('/home/kibb/projects/personal/tradewinds/priv/repo/seeds/europe/europe_exports.json') as f:
        exports = json.load(f)

    traders = [
    {'id': '2f4077b7-c8a8-43a0-981a-8729df419294', 'port_id': 'd81c4b0e-3de6-4666-8672-d95db02d8ade', 'name': 'London Trader'},
    {'id': '532fc454-201b-4493-9935-823e056a9ab3', 'port_id': '7ad3c71d-88e1-4b3e-bc2c-e5a08e9b9d56', 'name': 'Bristol Trader'},
    {'id': '95adac0e-9c03-44b5-9855-9a47141bc32f', 'port_id': '9b7e3979-fa0f-4179-b3d3-8c57dc97ed61', 'name': 'Plymouth Trader'},
    {'id': '981de71c-999f-4b6f-ac3d-89cecb0a36fd', 'port_id': 'fe9fec8c-5f40-4014-ae86-ea36efab1d94', 'name': 'Liverpool Trader'},
    {'id': 'e975e6e1-e7b6-4462-a913-9a35d9c88fcf', 'port_id': '0e655474-e3fc-432f-a649-c90be00e5a43', 'name': 'Leith Trader'},
    {'id': 'ea054f99-283b-4010-b4c9-43babe19747d', 'port_id': 'fffc54aa-b96b-4786-bc78-6d819e952df5', 'name': 'Glasgow Trader'},
    {'id': 'bbe60712-c63e-4c0a-9f9d-60e7c6c0ee92', 'port_id': 'aef5d826-0609-495b-990e-dde20e37e32e', 'name': 'Dublin Trader'},
    {'id': 'c6a02991-6ae3-4076-aca7-1457d95b3ece', 'port_id': 'ad8cbf11-0c2e-4c31-884a-7aa00eb04f86', 'name': 'Amsterdam Trader'},
    {'id': '9ba86a7f-7afb-4f9d-ba1c-8c03b79032fd', 'port_id': 'e5b68daa-57b2-4740-a4e2-663215dce6c4', 'name': 'Rotterdam Trader'},
    {'id': '11487839-16de-4946-ae70-8cb3b527d10e', 'port_id': '1843d7ce-7697-4697-8fb4-d687318418ee', 'name': 'Middelburg Trader'},
    {'id': '64d38b58-9ba6-4973-8ff9-f4b27765e937', 'port_id': 'f7950879-1c46-4f12-b940-c9df653ab30a', 'name': 'Antwerp Trader'},
    {'id': '53d8bc0b-78cd-4956-b594-c8598fedbd86', 'port_id': '8f5df117-033b-4acd-87e5-9341028e606e', 'name': 'Rouen Trader'},
    {'id': 'cc2d4d13-ae2f-4ef6-8e2a-65bfd918215a', 'port_id': 'e76d42d3-4c15-4f25-94f4-9e8ed9bad2fb', 'name': 'La Rochelle Trader'},
    {'id': 'f5304555-975e-4586-8b39-39fc959ae2e6', 'port_id': 'cc52c98e-986c-41a0-83f3-2503a31fa713', 'name': 'Bordeaux Trader'},
    {'id': 'cc7079e0-cfc4-4f7b-a686-165075a39c8e', 'port_id': '2fef6501-de3d-4174-8b06-f04f88e8ab81', 'name': 'Marseille Trader'},
    {'id': '2c576407-e5cf-41f7-9a92-e47ede6a37a6', 'port_id': 'c71aa186-ae51-443a-8d7b-2fde79090c6d', 'name': 'Seville Trader'},
    {'id': 'bfd065ae-9ce4-4dd3-a4c6-83e8a49d755c', 'port_id': 'ea8535c8-a2c5-4815-b990-ee5e518ce97a', 'name': 'Cadiz Trader'},
    {'id': '4ddf54a5-72cc-403e-85ca-a44cedcaeed4', 'port_id': 'ba69d0fb-06e3-4d3e-86c9-241c4f5a4d4b', 'name': 'Barcelona Trader'},
    {'id': 'ab4717b2-193f-4397-9ef4-2e234b74573e', 'port_id': '8b616fa7-581b-4cf2-abdd-a47ffca21c9c', 'name': 'Lisbon Trader'},
    {'id': '9bce0fad-23c0-409a-a081-f6b9d5ae4386', 'port_id': 'cb10fb16-a20d-47ae-80b2-c802bde3f647', 'name': 'Porto Trader'},
    {'id': 'bdae6f96-9831-4f80-b985-558c6aeff253', 'port_id': '560e5486-0761-4884-a988-d28a86a98885', 'name': 'Venice Trader'},
    {'id': '811e68d8-2c5b-4fbe-9bf7-75b9ab432c6b', 'port_id': 'a6acb399-5971-4456-97fb-9228d392ca98', 'name': 'Genoa Trader'},
    {'id': 'cddba3ca-3df1-4533-b552-6170caaa7bd0', 'port_id': '8a2c3456-e432-414f-9392-873f5a5c567a', 'name': 'Naples Trader'},
    {'id': '15763f29-40ed-47dc-bbc5-364d82b62180', 'port_id': '39c7a069-c7dd-48d3-a4bc-bd76a4d2658e', 'name': 'Livorno Trader'},
    {'id': '39836b38-04aa-4025-82c2-f8811936e7d3', 'port_id': '47e2f4dc-5b7f-44eb-bdf9-c8fc11e7a3e9', 'name': 'Ancona Trader'},
    {'id': '3c064489-6828-4784-9efe-ba32c0b2ad1e', 'port_id': 'a5e35981-0636-40be-9589-7c302015a76a', 'name': 'Valletta Trader'},
    {'id': '4f0f8089-5425-45b5-9d8e-1e081dc47927', 'port_id': '1a654123-c5bb-45a3-bd40-18d352e8d574', 'name': 'Constantinople Trader'},
    {'id': '9a5f485e-9b17-4e39-9eea-39cfe1e77a85', 'port_id': '9264c219-6eea-474f-8529-3d330609f218', 'name': 'Izmir Trader'},
    {'id': 'df64ff29-9a6f-4b83-9d40-19f6978e1319', 'port_id': '63cd1294-497b-4af7-b8d5-fd483df22c09', 'name': 'Thessaloniki Trader'},
    {'id': '0d746ae2-e8c2-4c54-a6f0-19f7bf8f2b06', 'port_id': '460aa674-cbd1-46eb-8edd-ac680d14a471', 'name': 'Copenhagen Trader'},
    {'id': 'b3f55463-7da1-4009-a935-7404df1da242', 'port_id': '16d11f21-a6d8-4cef-9677-4a23939d56de', 'name': 'Stockholm Trader'},
    {'id': 'd7850dd4-ac8d-4012-ac81-d92de5e41fd6', 'port_id': '2cad1167-01e3-42f8-b42a-f526ca59cf24', 'name': 'Bergen Trader'},
    {'id': 'e53ca11f-a6d7-43a2-ab0d-4610b66e76f0', 'port_id': '01690c9d-4748-4cac-b1fe-3048b7490f25', 'name': 'Hamburg Trader'},
    {'id': 'f02c4e63-f555-45e7-a5e1-78748b4986fb', 'port_id': '2df906cb-0e75-40b4-b1b3-4b8a99ce7720', 'name': 'Lübeck Trader'},
    {'id': '45858c03-24b1-46aa-b56c-94e55591a49e', 'port_id': 'e0ddf911-aefc-4b5c-8e58-4b7c2961127f', 'name': 'Bremen Trader'},
    {'id': '0b4b2185-5a1c-4b5d-b12e-5344c59be1ed', 'port_id': '13b74ed7-293f-44a6-a360-194cae605986', 'name': 'Gdańsk Trader'},
    {'id': '308c6304-0217-47a1-b28e-367f0f1657f0', 'port_id': '82e12706-643e-41aa-9707-7b5098d587c9', 'name': 'Arkhangelsk Trader'}
]
    ports = [
    {'id': 'd81c4b0e-3de6-4666-8672-d95db02d8ade', 'name': 'London'},
    {'id': '7ad3c71d-88e1-4b3e-bc2c-e5a08e9b9d56', 'name': 'Bristol'},
    {'id': '9b7e3979-fa0f-4179-b3d3-8c57dc97ed61', 'name': 'Plymouth'},
    {'id': 'fe9fec8c-5f40-4014-ae86-ea36efab1d94', 'name': 'Liverpool'},
    {'id': '0e655474-e3fc-432f-a649-c90be00e5a43', 'name': 'Leith'},
    {'id': 'fffc54aa-b96b-4786-bc78-6d819e952df5', 'name': 'Glasgow'},
    {'id': 'aef5d826-0609-495b-990e-dde20e37e32e', 'name': 'Dublin'},
    {'id': 'ad8cbf11-0c2e-4c31-884a-7aa00eb04f86', 'name': 'Amsterdam'},
    {'id': 'e5b68daa-57b2-4740-a4e2-663215dce6c4', 'name': 'Rotterdam'},
    {'id': '1843d7ce-7697-4697-8fb4-d687318418ee', 'name': 'Middelburg'},
    {'id': 'f7950879-1c46-4f12-b940-c9df653ab30a', 'name': 'Antwerp'},
    {'id': '8f5df117-033b-4acd-87e5-9341028e606e', 'name': 'Rouen'},
    {'id': 'e76d42d3-4c15-4f25-94f4-9e8ed9bad2fb', 'name': 'La Rochelle'},
    {'id': 'cc52c98e-986c-41a0-83f3-2503a31fa713', 'name': 'Bordeaux'},
    {'id': '2fef6501-de3d-4174-8b06-f04f88e8ab81', 'name': 'Marseille'},
    {'id': 'c71aa186-ae51-443a-8d7b-2fde79090c6d', 'name': 'Seville'},
    {'id': 'ea8535c8-a2c5-4815-b990-ee5e518ce97a', 'name': 'Cadiz'},
    {'id': 'ba69d0fb-06e3-4d3e-86c9-241c4f5a4d4b', 'name': 'Barcelona'},
    {'id': '8b616fa7-581b-4cf2-abdd-a47ffca21c9c', 'name': 'Lisbon'},
    {'id': 'cb10fb16-a20d-47ae-80b2-c802bde3f647', 'name': 'Porto'},
    {'id': '560e5486-0761-4884-a988-d28a86a98885', 'name': 'Venice'},
    {'id': 'a6acb399-5971-4456-97fb-9228d392ca98', 'name': 'Genoa'},
    {'id': '8a2c3456-e432-414f-9392-873f5a5c567a', 'name': 'Naples'},
    {'id': '39c7a069-c7dd-48d3-a4bc-bd76a4d2658e', 'name': 'Livorno'},
    {'id': '47e2f4dc-5b7f-44eb-bdf9-c8fc11e7a3e9', 'name': 'Ancona'},
    {'id': 'a5e35981-0636-40be-9589-7c302015a76a', 'name': 'Valletta'},
    {'id': '1a654123-c5bb-45a3-bd40-18d352e8d574', 'name': 'Constantinople'},
    {'id': '9264c219-6eea-474f-8529-3d330609f218', 'name': 'Izmir'},
    {'id': '63cd1294-497b-4af7-b8d5-fd483df22c09', 'name': 'Thessaloniki'},
    {'id': '460aa674-cbd1-46eb-8edd-ac680d14a471', 'name': 'Copenhagen'},
    {'id': '16d11f21-a6d8-4cef-9677-4a23939d56de', 'name': 'Stockholm'},
    {'id': '2cad1167-01e3-42f8-b42a-f526ca59cf24', 'name': 'Bergen'},
    {'id': '01690c9d-4748-4cac-b1fe-3048b7490f25', 'name': 'Hamburg'},
    {'id': '2df906cb-0e75-40b4-b1b3-4b8a99ce7720', 'name': 'Lübeck'},
    {'id': 'e0ddf911-aefc-4b5c-8e58-4b7c2961127f', 'name': 'Bremen'},
    {'id': '13b74ed7-293f-44a6-a360-194cae605986', 'name': 'Gdańsk'},
    {'id': '82e12706-643e-41aa-9707-7b5098d587c9', 'name': 'Arkhangelsk'}
]
    items = [
    {'id': '32379cee-ed8b-46ec-b463-28c22c0947f0', 'name': 'Beer'},
    {'id': 'c6c15eac-defa-469d-8a42-211d81639def', 'name': 'Books'},
    {'id': 'ed7429fd-f0ec-4f23-8336-92284bacc843', 'name': 'Charcoal'},
    {'id': '66d9bd2b-d8cc-4135-ba93-b2602cb95ddd', 'name': 'Cloth'},
    {'id': '1393b067-7492-40bb-8ddf-38b97dbc6f79', 'name': 'Coal'},
    {'id': 'f3d4a178-61d2-46e1-abec-da6f26194196', 'name': 'Coffee'},
    {'id': '16ee0306-ac49-4d6a-8c56-52754a75eee7', 'name': 'Copper'},
    {'id': '38dcd6e0-fbe5-4e92-aab6-d54e58d11530', 'name': 'Cotton'},
    {'id': '3797f943-716f-466a-9264-46b3313ede8b', 'name': 'Dyes'},
    {'id': '085cbf02-3902-4103-b3b1-5c6a55083b3b', 'name': 'Fish'},
    {'id': 'be76445b-89f5-4b2a-b4a6-ee664b6068eb', 'name': 'Furs'},
    {'id': '05e53a02-3a7e-42d2-8c57-37478169851e', 'name': 'Glassware'},
    {'id': '8fe811ef-3ebd-4472-8ed8-39cb631c9444', 'name': 'Gold'},
    {'id': '61f59db2-434d-4313-a4c5-47fcbe01652b', 'name': 'Grain'},
    {'id': '2a9bb9ec-6032-4492-b70b-64eaf4a2d1c6', 'name': 'Hardwood'},
    {'id': '3ae658d2-8b66-467c-b03e-30aed8f34a2e', 'name': 'Hops'},
    {'id': 'ee3a8035-739f-432b-9b94-ba1c9b1f9811', 'name': 'Instruments'},
    {'id': '9f75e9a4-4479-4b8a-9cfa-2f65702d8583', 'name': 'Iron'},
    {'id': '8d1fecd0-0337-4fc4-baa3-499487cf7123', 'name': 'Ivory'},
    {'id': 'ebf80841-69b6-494c-a4d4-11a22faefba5', 'name': 'Jewelry'},
    {'id': '4bfc5d66-98a2-48ee-b578-b6e30e407570', 'name': 'Linen'},
    {'id': '803b5028-ae15-4fde-b2b9-b39a44dcd6b2', 'name': 'Luxury Fabrics'},
    {'id': '867e1c10-b1e0-4c93-bd2b-0c4c0591e0e3', 'name': 'Marble'},
    {'id': '779bf707-c928-4f7f-b1d5-b7e142fc8b2e', 'name': 'Metalwares'},
    {'id': 'cb3a28c9-97e9-4c39-a4e5-0ced6533b1c6', 'name': 'Olive Oil'},
    {'id': '36c7074c-38ff-4359-a513-88938ba67989', 'name': 'Paper'},
    {'id': '72296dc6-ca1f-4eab-af57-4bcb040c420f', 'name': 'Porcelain'},
    {'id': 'cc8dd535-f84c-48ea-8979-ff215204cee7', 'name': 'Pottery'},
    {'id': 'dbf0d89f-f747-4961-89b3-a4f0c8f60867', 'name': 'Rice'},
    {'id': '47b74268-42b0-46c8-bc44-91f32fb156c2', 'name': 'Rum'},
    {'id': '3f6da5eb-89f2-4bd6-bcf8-f56ad384f58a', 'name': 'Salt'},
    {'id': 'cba674cb-96bf-4499-a50b-e209da8edab1', 'name': 'Silk'},
    {'id': '023e6a43-964b-494a-923d-8cab3e116a42', 'name': 'Silver'},
    {'id': '8331e26f-5182-4434-baf5-8e8491924dd4', 'name': 'Spices'},
    {'id': '8877797c-b392-45ec-851b-a069cd497207', 'name': 'Spirits'},
    {'id': '6157fba5-bcc8-48d6-8562-b0e3f7984b89', 'name': 'Sugar'},
    {'id': 'dd487314-ff38-4b6f-9515-5675a5715904', 'name': 'Supplies'},
    {'id': 'b6b9aba1-de98-4303-86fb-c4c12331084e', 'name': 'Tea'},
    {'id': '174449b7-6611-4262-ba9f-8bfcebf252a7', 'name': 'Textile Fibers'},
    {'id': 'f2f9c37c-7352-46a5-afdf-809debd69b8c', 'name': 'Timber'},
    {'id': 'f789677a-8068-4821-bdf7-f848c853b487', 'name': 'Tobacco'},
    {'id': '1e080c3c-90f6-48e5-974d-3115541b6228', 'name': 'Weapons'},
    {'id': '76028d4b-37f8-48ea-a3b2-86c768191ce2', 'name': 'Whale Oil'},
    {'id': 'a115d2fe-ba47-440d-bb81-01f820eab329', 'name': 'Wine'},
    {'id': 'a82fa49d-e116-4727-8a18-4fe997263625', 'name': 'Wool'}
]

    plans = generate_trader_plans(traders, ports, items, exports)
    sql_inserts = generate_sql_inserts(plans)

    with open('/home/kibb/projects/personal/tradewinds/tradewinds-py/insert_plans.sql', 'w') as f:
        for sql in sql_inserts:
            f.write(sql + '\n')