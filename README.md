# cyanodbc
A Cython Wrapper for Nanodbc

## Testing
1. Start up a SQL Server docker image to test SQL functionality.
Instructions can be found at: https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017

The main command is 
```
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Passw0rd"    -p 1433:1433 --name sql1    -d microsoft/mssql-server-linux:2017-latest
```



