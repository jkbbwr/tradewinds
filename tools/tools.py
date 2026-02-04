import searoute
import typer
import json
import difflib
from pathlib import Path

app = typer.Typer()


@app.command()
def lookup_port(name: str):
    ports_file = Path(__file__).parent / "ports.json"
    try:
        with open(ports_file, "r") as f:
            ports_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {ports_file} not found.")
        return

    cities = [p.get("CITY", "") for p in ports_data]
    matches = difflib.get_close_matches(name, cities, n=1, cutoff=0.6)

    if not matches:
        print(f"No port found matching '{name}'.")
        return

    best_match_name = matches[0]
    
    # Find the first port with this name
    port = next((p for p in ports_data if p.get("CITY") == best_match_name), None)

    if port:
        country = port.get('COUNTRY', 'Unknown')
        lat = port.get('LATITUDE')
        lon = port.get('LONGITUDE')
        if name.lower() != best_match_name.lower():
            print(f"I couldn't find '{name}', but I found a similar port: '{best_match_name}'")
        print(f"Port: {best_match_name}, {country}")
        print(f"Latitude: {lat}")
        print(f"Longitude: {lon}")



@app.command()
def distance(origin_lat: float, origin_long: float, dest_lat: float, dest_long: float):
    route = searoute.searoute(
        [origin_lat, origin_long], [dest_lat, dest_long], units="naut"
    )

    print("{:.0f} {}".format(route.properties["length"], route.properties["units"]))


if __name__ == "__main__":
    app()
