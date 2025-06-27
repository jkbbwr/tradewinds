
import psycopg2
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderUnavailable
import contextily as ctx

def get_db_connection():
    """Establishes a connection to the PostgreSQL database."""
    try:
        conn = psycopg2.connect(
            dbname="tradewinds_dev",
            user="postgres",
            password="postgres", # Replace with your actual password if needed
            host="localhost"
        )
        return conn
    except psycopg2.OperationalError as e:
        print(f"Error: Could not connect to the database. {e}")
        return None

def fetch_countries(conn):
    """Fetches all country names from the database."""
    countries = []
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT name FROM country;")
            rows = cur.fetchall()
            countries = [row[0] for row in rows]
    except psycopg2.Error as e:
        print(f"Error: Could not fetch countries. {e}")
    return countries

def fetch_ports_with_countries(conn):
    """Fetches all port names with their country names from the database."""
    ports = []
    try:
        with conn.cursor() as cur:
            cur.execute("""
                SELECT p.name, c.name as country_name
                FROM port p
                JOIN country c ON p.country_id = c.id;
            """)
            rows = cur.fetchall()
            ports = [{"name": row[0], "country": row[1]} for row in rows]
    except psycopg2.Error as e:
        print(f"Error: Could not fetch ports. {e}")
    return ports

def get_coordinates(query, geolocator):
    """
    Geocodes a query string to get its latitude and longitude.
    Handles potential timeouts and service availability issues.
    """
    try:
        location = geolocator.geocode(query, timeout=10)
        if location:
            return (location.longitude, location.latitude)
        else:
            print(f"Warning: Could not find coordinates for '{query}'.")
            return None
    except (GeocoderTimedOut, GeocoderUnavailable) as e:
        print(f"Warning: Geocoding service error for '{query}': {e}")
        return None

def plot_map(country_coords, port_coords):
    """Plots the countries and ports on a map of Europe."""
    fig = plt.figure(figsize=(12, 10))
    # Use a projection suitable for web maps
    ax = fig.add_subplot(1, 1, 1, projection=ccrs.Mercator())

    # Set the extent to Europe
    ax.set_extent([-10, 40, 35, 70], crs=ccrs.PlateCarree())

    # Add the high-quality basemap
    ctx.add_basemap(ax, source=ctx.providers.CartoDB.Positron)

    # Plot country markers and labels
    for country, coords in country_coords.items():
        ax.plot(
            coords[0],
            coords[1],
            "ro",
            markersize=7,
            transform=ccrs.Geodetic(),
            label=country,
        )
        ax.text(
            coords[0] + 0.5,
            coords[1] + 0.5,
            country,
            transform=ccrs.Geodetic(),
            fontsize=9,
            fontweight="bold",
            path_effects=[
                plt.matplotlib.patheffects.withStroke(linewidth=2, foreground="w")
            ],
        )

    # Plot port markers
    for port, coords in port_coords.items():
        ax.plot(
            coords[0],
            coords[1],
            "bo",
            markersize=4,
            transform=ccrs.Geodetic(),
            label=port,
        )

    plt.title("Tradewinds World Map")
    plt.savefig("tradewinds_map.png", dpi=300)
    print("Map saved to tradewinds_map.png")

def main():
    """Main function to orchestrate the script."""
    conn = get_db_connection()
    if not conn:
        return

    countries = fetch_countries(conn)
    ports = fetch_ports_with_countries(conn)
    conn.close()

    if not countries and not ports:
        print("No countries or ports found in the database.")
        return

    geolocator = Nominatim(user_agent="tradewinds_map_plotter")

    country_coordinates = {}
    for country in countries:
        query = "Vatican City" if country == "Papal States" else country
        coords = get_coordinates(query, geolocator)
        if coords:
            country_coordinates[country] = coords

    port_coordinates = {}
    for port in ports:
        query = f"{port['name']}, {port['country']}"
        coords = get_coordinates(query, geolocator)
        if coords:
            port_coordinates[port['name']] = coords

    if not country_coordinates and not port_coordinates:
        print("Could not geocode any locations. Cannot generate map.")
        return

    plot_map(country_coordinates, port_coordinates)

if __name__ == "__main__":
    main()
