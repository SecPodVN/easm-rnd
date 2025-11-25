"""
Quick API Test Script
Run this after Docker containers are up to verify the Example API is working.

Usage:
    python test_api.py
"""
import requests
import json
from typing import Dict, Any

BASE_URL = "http://localhost:8000/api"

def print_section(title: str):
    """Print a section header."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")

def print_response(response: requests.Response):
    """Pretty print response."""
    print(f"Status: {response.status_code}")
    try:
        print(f"Response: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"Response: {response.text}")
    print()

def test_api_root():
    """Test API root endpoint."""
    print_section("1. Testing API Root")
    response = requests.get(f"{BASE_URL}/")
    print_response(response)
    return response.status_code == 200

def test_health():
    """Test health endpoint."""
    print_section("2. Testing Health Endpoint")
    response = requests.get(f"{BASE_URL}/health/")
    print_response(response)
    return response.status_code == 200

def test_get_token(username: str = "admin", password: str = "admin") -> str:
    """Get JWT token."""
    print_section("3. Getting JWT Token")
    response = requests.post(
        f"{BASE_URL}/token/",
        json={"username": username, "password": password}
    )
    print_response(response)

    if response.status_code == 200:
        return response.json().get("access", "")
    return ""

def test_list_todos(token: str):
    """Test listing todos."""
    print_section("4. Testing List Todos (GET /api/example/)")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/example/", headers=headers)
    print_response(response)
    return response.status_code == 200

def test_create_todo(token: str) -> int:
    """Test creating a todo."""
    print_section("5. Testing Create Todo (POST /api/example/)")
    headers = {"Authorization": f"Bearer {token}"}
    data = {
        "title": "Test Todo from API Test Script",
        "description": "This validates the new architecture is working",
        "priority": "high",
        "status": "pending"
    }
    response = requests.post(f"{BASE_URL}/example/", headers=headers, json=data)
    print_response(response)

    if response.status_code == 201:
        return response.json().get("id", 0)
    return 0

def test_get_todo(token: str, todo_id: int):
    """Test getting a specific todo."""
    print_section(f"6. Testing Get Todo (GET /api/example/{todo_id}/)")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/example/{todo_id}/", headers=headers)
    print_response(response)
    return response.status_code == 200

def test_update_todo(token: str, todo_id: int):
    """Test updating a todo."""
    print_section(f"7. Testing Update Todo (PATCH /api/example/{todo_id}/)")
    headers = {"Authorization": f"Bearer {token}"}
    data = {"priority": "medium", "description": "Updated via test script"}
    response = requests.patch(f"{BASE_URL}/example/{todo_id}/", headers=headers, json=data)
    print_response(response)
    return response.status_code == 200

def test_complete_todo(token: str, todo_id: int):
    """Test marking todo as complete."""
    print_section(f"8. Testing Complete Todo (POST /api/example/{todo_id}/complete/)")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post(f"{BASE_URL}/example/{todo_id}/complete/", headers=headers)
    print_response(response)
    return response.status_code == 200

def test_user_stats(token: str):
    """Test getting user statistics."""
    print_section("9. Testing User Stats (GET /api/example/stats/)")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/example/stats/", headers=headers)
    print_response(response)
    return response.status_code == 200

def test_overdue_todos(token: str):
    """Test getting overdue todos."""
    print_section("10. Testing Overdue Todos (GET /api/example/overdue/)")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/example/overdue/", headers=headers)
    print_response(response)
    return response.status_code == 200

def main():
    """Run all tests."""
    print("\n" + "="*60)
    print("  EASM API - Example Domain Tests")
    print("="*60)
    print("\nThis script tests the newly restructured API architecture.")
    print("Ensure Docker containers are running before proceeding.\n")

    input("Press Enter to start tests...")

    results = []

    # Test API basics
    results.append(("API Root", test_api_root()))
    results.append(("Health Check", test_health()))

    # Get token
    token = test_get_token()
    if not token:
        print("\n❌ Failed to get JWT token. Cannot proceed with authenticated tests.")
        print("Make sure you have created a superuser:")
        print("  docker exec -it <container> python manage.py createsuperuser")
        return

    results.append(("Get JWT Token", True))

    # Test Example API endpoints
    results.append(("List Todos", test_list_todos(token)))

    todo_id = test_create_todo(token)
    results.append(("Create Todo", todo_id > 0))

    if todo_id:
        results.append(("Get Todo Detail", test_get_todo(token, todo_id)))
        results.append(("Update Todo", test_update_todo(token, todo_id)))
        results.append(("Complete Todo", test_complete_todo(token, todo_id)))

    results.append(("User Stats", test_user_stats(token)))
    results.append(("Overdue Todos", test_overdue_todos(token)))

    # Print summary
    print_section("Test Summary")
    passed = sum(1 for _, result in results if result)
    total = len(results)

    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")

    print(f"\n{'='*60}")
    print(f"Results: {passed}/{total} tests passed")
    print(f"{'='*60}\n")

    if passed == total:
        print("🎉 All tests passed! The Example API is working correctly.")
        print("\nThe new architecture is properly configured:")
        print("  ✓ config/settings/ - Settings management")
        print("  ✓ apps/core/ - Shared utilities")
        print("  ✓ apps/authentication/ - Auth layer")
        print("  ✓ apps/example/ - Domain logic")
        print("  ✓ apps/api/ - Presentation layer")
        print("  ✓ common/ - Shared code")
    else:
        print("⚠️  Some tests failed. Check the output above for details.")

if __name__ == "__main__":
    try:
        main()
    except requests.exceptions.ConnectionError:
        print("\n❌ Connection Error!")
        print("Docker containers are not running or not accessible.")
        print("\nStart them with:")
        print("  .\\skaffold.ps1")
        print("\nOr check if services are up:")
        print("  docker ps")
    except KeyboardInterrupt:
        print("\n\nTests cancelled by user.")
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
