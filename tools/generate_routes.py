import json
import subprocess
from pathlib import Path
import searoute

# Define all the ports from seeds.exs with their specific countries to avoid fuzzy match errors (like London, USA)
seeded_ports = [
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
    ("Dublin", "Ireland")
]

def _find_port(name: str, country: str):
    ports_file = Path(__file__).parent / "ports.json"
    with open(ports_file, "r") as f:
        ports_data = json.load(f)
    
    # Filter by both city name AND country to ensure we stay in Europe
    candidates = [p for p in ports_data if p.get("CITY") == name and p.get("COUNTRY") == country]
    if candidates:
        return candidates[0]
    
    # Fallback to city match if country fails (but shouldn't for these)
    candidates = [p for p in ports_data if p.get("CITY") == name]
    if candidates:
        return candidates[0]
        
    return None

def generate_routes():
    features = []
    
    # Generate route combinations
    for i in range(len(seeded_ports)):
        for j in range(i + 1, len(seeded_ports)):
            p1_name, p1_country = seeded_ports[i]
            p2_name, p2_country = seeded_ports[j]
            
            p1 = _find_port(p1_name, p1_country)
            p2 = _find_port(p2_name, p2_country)
            
            if not p1 or not p2:
                print(f"Skipping {p1_name} to {p2_name}")
                continue
                
            try:
                # searoute expects [lon, lat]
                route = searoute.searoute(
                    [p1.get("LONGITUDE"), p1.get("LATITUDE")], 
                    [p2.get("LONGITUDE"), p2.get("LATITUDE")], 
                    units="naut"
                )
                
                # Add route names to properties so frontend can match it
                route["properties"]["from"] = p1_name
                route["properties"]["to"] = p2_name
                features.append(route)
            except Exception as e:
                print(f"Failed to route {p1_name} to {p2_name}: {e}")
                
    feature_collection = {
        "type": "FeatureCollection",
        "features": features
    }
    
    # Write to assets/routes.json
    out_dir = Path(__file__).parent.parent / "assets"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_file = out_dir / "routes.json"
    
    with open(out_file, "w") as f:
        json.dump(feature_collection, f)
        
    print(f"Generated {len(features)} routes to {out_file}")

if __name__ == "__main__":
    generate_routes()
