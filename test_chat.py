import requests
import json

url = 'http://localhost:5000/chat'
headers = {'Content-Type': 'application/json'}
data = {'message': 'cari laptop gaming 15 jutaan'}

try:
    response = requests.post(url, headers=headers, json=data)
    print(f"Status Code: {response.status_code}")
    print("Response JSON:")
    print(json.dumps(response.json(), indent=2))
except Exception as e:
    print(f"Error: {e}")
