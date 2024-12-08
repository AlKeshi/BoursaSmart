import requests
import csv
import time
from datetime import datetime, timedelta

# Define the API URL
url = "						https://www.bvmt.com.tn/rest_api/rest/market/groups/11,12,52,95,99"

# Define the CSV file name
file_name = "market_data.csv"

# Write header if file does not exist
try:
    with open(file_name, 'x', newline='', encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow([
            "Time", "Valeur", "ISIN", "Statut", "Ord.A", "Qté.A", "Achat",
            "Vente", "Qté.V", "Ord.V", "Cours de référence", "Dernier", 
            "Var %", "Dern Qté", "Qté", "Capit", "P.Haut", "P.Bas", "Heure"
        ])
except FileExistsError:
    pass

# Function to fetch and append data
def fetch_and_store_data():
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        table_data = []

        # Parse the JSON response
        for item in data['markets']:
            row = {
                "Time": datetime.now(),
                "Valeur": item['referentiel']['stockName'],
                "ISIN": item['referentiel'].get('isin', ''),
                "Statut": item.get('status', ''),
                "Ord.A": item['limit'].get('askOrd', 0),
                "Qté.A": item['limit'].get('askQty', 0),
                "Achat": item['limit'].get('ask', 0),
                "Vente": item['limit'].get('bid', 0),
                "Qté.V": item['limit'].get('bidQty', 0),
                "Ord.V": item['limit'].get('bidOrd', 0),
                "Cours de référence": item.get('close', 0),
                "Dernier": item.get('last', 0),
                "Var %": item.get('change', 0),
                "Dern Qté": item.get('trVolume', 0),
                "Qté": item.get('volume', 0),
                "Capit": item.get('caps', 0),
                "P.Haut": item.get('high', 0),
                "P.Bas": item.get('low', 0),
                "Heure": item['limit'].get('time', '')
            }
            table_data.append(row)

        # Append data to the CSV file
        with open(file_name, 'a', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            for row in table_data:
                writer.writerow([
                    row["Time"], row["Valeur"], row["ISIN"], row["Statut"], row["Ord.A"],
                    row["Qté.A"], row["Achat"], row["Vente"], row["Qté.V"], row["Ord.V"],
                    row["Cours de référence"], row["Dernier"], row["Var %"], row["Dern Qté"],
                    row["Qté"], row["Capit"], row["P.Haut"], row["P.Bas"], row["Heure"]
                ])
        print(f"Data successfully appended at {datetime.now()}")
    else:
        print(f"Failed to fetch data. Status Code: {response.status_code}")

fetch_and_store_data()