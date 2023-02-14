# LAST LOGON
Solve the problem created by Spanish government security recommendation (Esquema Nacional de Seguridad) 

This law establish the need to inform the user about the last logon made with his id

## Irule
The irule must save the last logon time in a persistent storage. As we need to do this with an iRule the most persistent storage we could write and read is the table and subtables (https://community.f5.com/t5/technical-articles/advanced-irules-tables/ta-p/290369)

## Policy

We need to display the session variable created in the Policy

## DEBUG
In order to debug, and to save the table we use the code in (https://community.f5.com/t5/technical-articles/session-table-control-with-irules/ta-p/282763)


