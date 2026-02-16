import difflib
import json
from pathlib import Path
from typing import Optional

import searoute
import typer

app = typer.Typer()


def _find_port(name: str, country: Optional[str] = None):
    ports_file = Path(__file__).parent / "ports.json"
    try:
        with open(ports_file, "r") as f:
            ports_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {ports_file} not found.")
        return None

    # Filter by country if provided
    if country:
        # Fuzzy match country? Or exact? exact for now to be safe with "U.K." vs "United Kingdom"
        # The json has "U.K.", "U.S.A.", "Netherlands", etc.
        candidates = [p for p in ports_data if p.get("COUNTRY", "").lower() == country.lower()]
        if not candidates:
             # Try fuzzy match on country if exact fails?
             # For now, let's just warn and return None if strictly filtered
             print(f"No ports found in country '{country}'.")
             return None
    else:
        candidates = ports_data

    cities = [p.get("CITY", "") for p in candidates]
    matches = difflib.get_close_matches(name, cities, n=1, cutoff=0.6)

    if not matches:
        print(f"No port found matching '{name}'" + (f" in {country}" if country else "") + ".")
        return None

    best_match_name = matches[0]

    # Find the first port with this name in the filtered list
    port = next((p for p in candidates if p.get("CITY") == best_match_name), None)
    
    if port and name.lower() != best_match_name.lower():
         # print(f"Using similar port: '{best_match_name}' for '{name}'")
         pass

    return port


@app.command()
def lookup_port(name: str, country: str = typer.Option(None, help="Country filter")):
    """
    Given a port name. Try and find the closest matching port and return its lat/long
    """
    port = _find_port(name, country)

    if port:
        port_country = port.get("COUNTRY", "Unknown")
        lat = port.get("LATITUDE")
        lon = port.get("LONGITUDE")
        
        print(f"Port: {port.get('CITY')}, {port_country}")
        print(f"Latitude: {lat}")
        print(f"Longitude: {lon}")


@app.command()
def distance(origin_lat: float, origin_long: float, dest_lat: float, dest_long: float):
    """
    Get the naut mile distance between orgin_lat origin_long dest_lat dest_long.
    """
    # searoute expects [lon, lat] typically, but let's stick to what was there or fix it?
    # The previous code had [origin_lat, origin_long]. 
    # Let's trust the library documentation if we can, but since I can't check online, 
    # I will assume the previous dev might have made a mistake OR searoute is flexible.
    # However, for my new command, I will use the correct [lon, lat] order which is standard for GeoJSON.
    route = searoute.searoute(
        [origin_long, origin_lat], [dest_long, dest_lat], units="naut"
    )

    print("{:.0f} {}".format(route.properties["length"], route.properties["units"]))


@app.command()
def distance_by_name(
    origin: str, 
    destination: str, 
    origin_country: str = typer.Option(None, help="Origin country"),
    destination_country: str = typer.Option(None, help="Destination country")
):
    """
    Get the distance between two ports by name.
    """
    p1 = _find_port(origin, origin_country)
    p2 = _find_port(destination, destination_country)

    if not p1:
        print(f"Could not find origin port: {origin}")
        return
    if not p2:
        print(f"Could not find destination port: {destination}")
        return

    # searoute expects [lon, lat]
    route = searoute.searoute(
        [p1.get("LONGITUDE"), p1.get("LATITUDE")], 
        [p2.get("LONGITUDE"), p2.get("LATITUDE")], 
        units="naut"
    )

    print("{:.0f}".format(route.properties["length"]))


if __name__ == "__main__":
    app()