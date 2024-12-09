This workflow, `main.dig`, is designed to create multiple parent segments based on the YAML templates provided in the config/templates folder.

Please follow these instructions to use the workflow:

1. Define YAML templates:
- Place the provided YAML template files in the config/templates folder.
2. Set `site` and `database` according to your environments in the config/database.yml
- Table `automation_templates` table is used to import the YAML template name from config/templates folder
- Table `automation_parent_segments` table will store the parent segments created with the audience_id if successful; otherwise, it will contain error logs.
3. Set `run_type` to create, update and recreate.
4. `Run the main.dig workflow`