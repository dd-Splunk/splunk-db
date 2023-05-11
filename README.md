# Installation steps

1. Create `.env` file containing credentials from template
2. Generate all `.csv` files containing simulated data
3. Generate initialization `create-db.sql` file that contains
   - the MYSQL `splunk`user grants
   - tables schemas based on the corresponding csv file structure
   - table load based on the corresponding csv file content
4. Start the docker environment

- Splunk + apps
- MySQL DB server

5. Wait for DBConnect APIs to be online
6. Configure DBX using API calls

- create identity
- create DB connection to MySQL DB server

7. Enjoy

## To Do

- [X] Group generated content in one dir to avoid pushing to Git
- [X] Remove hardwired file/dirs ( like /data in Dockerfile)
- [X] Set timezone for both containers
- [ ] Review DB Creation and initialization ( too complex )
- [ ] `make up` fails as passwords are regenerated
- [X] Prepare for Splunk 9.x ( dbxquery is still flagged risky )
- [ ] dd
