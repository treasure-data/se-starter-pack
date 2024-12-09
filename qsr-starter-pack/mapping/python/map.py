import digdag
import json

def main(schema): 
    schema_change = json.loads(schema)
    processed_tables = []
    for table in schema_change:
        raw_table_name = table["raw_table_name"]
        src_table_name = table["src_table_name"]
        if table.get('columns', False): 
            columns = table["columns"]
        else: 
            columns = []

        # Generate the mapping string
        mappings = ", ".join(f"{value} AS {key}" for col in columns for key, value in col.items())

        # Add to the processed tables list
        processed_tables.append({
            "raw_table_name": raw_table_name,
            "src_table_name": src_table_name,
            "mappings": mappings
        })

    # Store the processed list in Digdag environment
    digdag.env.store({"schema_map": processed_tables})