import re
import json

def parse_routes_to_json(input_filepath, output_filepath):
    """
    Reads route data from a file, parses it, and writes it to a JSON file.

    Args:
        input_filepath (str): The path to the input file containing route lines.
        output_filepath (str): The path to the output JSON file.
    """
    routes = []
    # Regex to capture from_id, to_id, and distance
    # It looks for:
    #   - 'from_id: ' followed by an alphanumeric word (e.g., 'arg')
    #   - 'to_id: ' followed by an alphanumeric word (e.g., 'bre')
    #   - 'distance: ' followed by one or more digits
    pattern = re.compile(r'from_id:\s*(\w+)\.id,\s*to_id:\s*(\w+)\.id,\s*distance:\s*(\d+)')

    try:
        with open(input_filepath, 'r') as infile:
            for line in infile:
                match = pattern.search(line)
                if match:
                    # Extract captured groups
                    from_id = match.group(1).upper() # Convert to uppercase as per example
                    to_id = match.group(2).upper()   # Convert to uppercase as per example
                    distance = int(match.group(3))   # Convert distance to integer

                    routes.append({
                        "from": from_id,
                        "to": to_id,
                        "distance": distance
                    })
                else:
                    print(f"Warning: Line did not match expected format: {line.strip()}")

        with open(output_filepath, 'w') as outfile:
            json.dump(routes, outfile, indent=4) # Use indent for pretty printing

        print(f"Successfully parsed {len(routes)} routes and saved to {output_filepath}")

    except FileNotFoundError:
        print(f"Error: Input file '{input_filepath}' not found.")
    except Exception as e:
        print(f"An error occurred: {e}")

# --- How to use the script ---
if __name__ == "__main__":

    # Define your input and output file paths
    input_file = "/home/kibb/projects/personal/tradewinds/priv/repo/seeds/europe.exs"
    output_file = "/home/kibb/projects/personal/tradewinds/priv/repo/seeds/europe_routes.json"

    # Run the parsing function
    parse_routes_to_json(input_file, output_file)
