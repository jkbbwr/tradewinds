import json
from pathlib import Path
import searoute
import difflib

# Define all the ports from seeds.exs and new_ports expansion
seeded_ports = [
    # North Sea / Atlantic (Existing)
    ("London", "U.K."),
    ("Edinburgh", "U.K."),
    ("Bristol", "U.K."),
    ("Hull", "U.K."),
    ("Portsmouth", "U.K."),
    ("Plymouth", "U.K."),
    ("Glasgow", "U.K."),
    ("Amsterdam", "Netherlands"),
    ("Rotterdam", "Netherlands"),
    ("Hamburg", "Germany"),
    ("Bremen", "Germany"),
    ("Antwerp", "Belgium"),
    ("Dunkirk", "France"),
    ("Calais", "France"),
    ("Dublin", "Ireland"),
    # Mediterranean / Southern Expansion (New)
    ("Lisbon", "Portugal"),
    ("Barcelona", "Spain"),
    ("Marseille", "France"),
    ("Genoa", "Italy"),
    ("Venice", "Italy"),
    ("Naples", "Italy"),
    ("Piraeus", "Greece"),
    ("Istanbul", "Turkey"),
    ("Alexandria", "Egypt"),
    ("Cartagena", "Spain"),
]


def _find_port(name: str, country: str):
    ports_file = Path(__file__).parent / "ports.json"
    with open(ports_file, "r") as f:
        ports_data = json.load(f)

    # Filter by country first
    candidates = [
        p for p in ports_data if p.get("COUNTRY", "").lower() == country.lower()
    ]
    if not candidates:
        print(f"No ports found in country '{country}'.")
        return None

    cities = [p.get("CITY", "") for p in candidates]
    matches = difflib.get_close_matches(name, cities, n=1, cutoff=0.6)

    if not matches:
        print(f"No port found matching '{name}' in {country}.")
        return None

    best_match_name = matches[0]
    return next((p for p in candidates if p.get("CITY") == best_match_name), None)


def generate_routes():
    features = []
    print(f"Starting route generation for {len(seeded_ports)} ports...")

    # Generate route combinations
    for i in range(len(seeded_ports)):
        p1_name, p1_country = seeded_ports[i]
        p1 = _find_port(p1_name, p1_country)

        if not p1:
            print(f"Skipping {p1_name} (not found)")
            continue

        for j in range(i + 1, len(seeded_ports)):
            p2_name, p2_country = seeded_ports[j]
            p2 = _find_port(p2_name, p2_country)

            if not p2:
                print(f"Skipping {p2_name} (not found)")
                continue

            try:
                # searoute expects [lon, lat]
                route = searoute.searoute(
                    [p1.get("LONGITUDE"), p1.get("LATITUDE")],
                    [p2.get("LONGITUDE"), p2.get("LATITUDE")],
                    units="naut",
                )

                # Add route names to properties so frontend and seed can match it
                route["properties"]["from"] = p1_name
                route["properties"]["to"] = p2_name
                features.append(route)
                # print(f"Routed {p1_name} to {p2_name}: {route['properties']['length']:.0f} nm")
            except Exception as e:
                print(f"Failed to route {p1_name} to {p2_name}: {e}")

    feature_collection = {"type": "FeatureCollection", "features": features}

    # Write to assets/routes.json
    out_dir = Path(__file__).parent.parent / "assets"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "routes.json"

    with open(out_file, "w") as f:
        json.dump(feature_collection, f)

    print(f"Generated {len(features)} routes to {out_file}")


if __name__ == "__main__":
    generate_routes()
