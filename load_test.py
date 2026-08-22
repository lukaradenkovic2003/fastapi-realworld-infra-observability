import time
import requests

# Replace with your public AWS EC2 IP address and application port
BASE_URL = "PUBLIC EC2 IP"

def test_api():
    print(f"Starting load test on FastAPI app at {BASE_URL}...")
    
    session = requests.Session()
    
    # Generate a unique user so registration succeeds each time
    unique_id = int(time.time())
    register_payload = {
        "email": f"testuser_{unique_id}@example.com",
        "password": "SecurePassword123!"
    }

    try:
        # 1. Test registration (POST /api/users)
        print("[>] Sending registration request...")
        reg_response = session.post(f"{BASE_URL}/api/users", json=register_payload)
        print(f"Registration status: {reg_response.status_code}")

        # 2. Test login (POST /api/users/login)
        print("[>] Sending login request...")
        login_response = session.post(f"{BASE_URL}/api/users/login", json=register_payload)
        print(f"Login status: {login_response.status_code}")

    except Exception as e:
        print(f"Connection error occurred: {e}")

if __name__ == "__main__":
    # Sending a series of requests in a loop to bump up the counter for Prometheus/Grafana
    print("Starting automated request loop (15 iterations total)...")
    for i in range(15):
        print(f"\n--- Iteration {i+1} ---")
        test_api()
        time.sleep(1) # 1-second pause between requests
    
    print("\n[✔] Test completed! Check Grafana to see the metrics spike and the alert trigger.")