import json
import requests
import psycopg2




# Database connection details
db_config = {
    "host": "pg.pg4e.com",
    "port": 5432,
    "dbname": "pg4e_500bbbcc8c",
    "user": "pg4e_500bbbcc8c",
    "password": "your key"  # 
}

conn = None  
try:
    # Connect to the PostgreSQL database
    conn = psycopg2.connect(**db_config)
    cursor = conn.cursor()

    # Create table 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pokeapi (
            id INTEGER PRIMARY KEY,
            body JSONB
        );
    """)
    conn.commit()

    # Fetch and insert 
    for poke_id in range(1, 101):
        response = requests.get(f"https://pokeapi.co/api/v2/pokemon/{poke_id}")
        if response.status_code == 200:
            pokemon_data = response.json()
            # Convert the Python dictionary to a JSON string
            cursor.execute("""
                INSERT INTO pokeapi (id, body)
                VALUES (%s, %s)
                ON CONFLICT (id) DO NOTHING;
            """, (pokemon_data['id'], json.dumps(pokemon_data)))
        else:
            print(f"Failed to fetch data for Pokémon ID: {poke_id}")

    # Commit all changes
    conn.commit()
    print("Data successfully inserted!")

except psycopg2.Error as db_error:
    print(f"Database error: {db_error}")

except requests.RequestException as req_error:
    print(f"Request error: {req_error}")

except Exception as e:
    print(f"Unexpected error: {e}")

finally:
    if conn:  
        cursor.close()
        conn.close()