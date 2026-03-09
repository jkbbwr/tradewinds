import os
import time
from typing import Callable, Any
from dotenv import load_dotenv

from tradewinds_api_client import Client, AuthenticatedClient
from tradewinds_api_client.models import RegisterRequest, LoginRequest
from tradewinds_api_client.api.default import (
    tradewinds_web_auth_controller_register,
    tradewinds_web_auth_controller_login,
    tradewinds_web_auth_controller_revoke
)

# Load environment variables from .env file
load_dotenv()

def execute_with_rate_limit(func: Callable, *args, max_retries: int = 5, retry_delay: int = 2, **kwargs) -> Any:
    """Executes a function and retries if it hits a 429 Rate Limit."""
    for attempt in range(max_retries):
        response = func(*args, **kwargs)
        
        # Check if it's a detailed response object that has a status_code
        if hasattr(response, "status_code") and response.status_code == 429:
            print(f"Rate limited (429). Waiting {retry_delay} seconds before retry {attempt + 1}/{max_retries}...")
            time.sleep(retry_delay)
            continue
            
        return response
        
    print(f"Failed to execute after {max_retries} retries due to rate limiting.")
    return response

def main():
    base_url = os.getenv("API_BASE_URL", "http://localhost:4000")
    client = Client(base_url=base_url)

    # Check for existing credentials in .env
    email = os.getenv("PLAYER_EMAIL")
    password = os.getenv("PLAYER_PASSWORD")
    should_register = not (email and password)

    with client as c:
        if should_register:
            # Generate a unique email if none provided
            unique_id = int(time.time())
            email = f"testuser_{unique_id}@example.com"
            password = "SuperSecretPassword123!"
            name = f"Test User {unique_id}"

            print(f"No credentials found in .env. Attempting to register new account: {email}")
            register_request = RegisterRequest(
                email=email,
                name=name,
                password=password
            )

            register_response = execute_with_rate_limit(
                tradewinds_web_auth_controller_register.sync_detailed,
                client=c, 
                body=register_request
            )
            
            parsed_register = register_response.parsed if hasattr(register_response, "parsed") else register_response
            
            if hasattr(parsed_register, "data"):
                print(f"Registration successful! User ID: {parsed_register.data.id}")
                print("\n--- Registration Details ---")
                print(f"Email:    {email}")
                print(f"Password: {password}")
                print("----------------------------\n")
                print("Waiting for administrative approval...")
                input("Please enable the user in the admin panel and press Enter to continue to login...")
            else:
                print(f"Registration returned: status_code={getattr(register_response, 'status_code', 'Unknown')}, content={getattr(register_response, 'content', 'Unknown')}")
                return
        else:
            print(f"Found existing credentials in .env for: {email}. Skipping registration.")

        print("\nAttempting to log in...")
        login_request = LoginRequest(
            email=email, # type: ignore
            password=password # type: ignore
        )
        
        login_response = execute_with_rate_limit(
            tradewinds_web_auth_controller_login.sync_detailed,
            client=c, 
            body=login_request
        )
            
        parsed_login = login_response.parsed if hasattr(login_response, "parsed") else login_response
        
        token = None
        if hasattr(parsed_login, "data") and hasattr(parsed_login.data, "token"):
            token = parsed_login.data.token
            print(f"Login successful! Token: {token[:20]}...")
        else:
            print(f"Login failed or unexpected response: status_code={getattr(login_response, 'status_code', 'Unknown')}, content={getattr(login_response, 'content', 'Unknown')}")

    # Now revoke the token if one was successfully generated
    if token:
        print("\nAttempting to revoke token...")
        auth_client = AuthenticatedClient(base_url=base_url, token=token)
        with auth_client as ac:
            revoke_response = execute_with_rate_limit(
                tradewinds_web_auth_controller_revoke.sync_detailed,
                client=ac
            )
            if hasattr(revoke_response, "status_code") and revoke_response.status_code == 204:
                print("Token successfully revoked.")
            else:
                print(f"Token revocation failed: status_code={getattr(revoke_response, 'status_code', 'Unknown')}, content={getattr(revoke_response, 'content', 'Unknown')}")


if __name__ == "__main__":
    main()
