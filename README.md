# LAST LOGON
Solve the problem created by Spanish government security recommendation (Esquema Nacional de Seguridad) 

This law establish the need to inform the user about the last logon made with his id

## Irule
The irule must save the last logon time in a persistent storage. As we need to do this with an iRule the most persistent storage we could write and read is the table and subtables (https://community.f5.com/t5/technical-articles/advanced-irules-tables/ta-p/290369)

## Policy

We need to add an iRule box with the id "lastLogonTime" in order to trig the irule
We need to display the session variable created in the Policy just needed to add a message box con el valor "Ultimo acceso de usuario en la fecha y hora: %{session.custom.previousLastLogon}"

## DEBUG
In order to debug, and to save the table we use a customized code derived from  (https://community.f5.com/t5/technical-articles/session-table-control-with-irules/ta-p/282763)

# TO TAKE IN ACCOUNT
* Both irules must be added to VS
* Tables are deleted in case of reboot
* A backup could be done via the url /gestion/export/llt
** A simple curl -k https://<VirtualServerIP>/gestion/export/llt > backup.csv could be used to automate backup in crontab daily
* Tables are stored in memory and no limits are set for storing them (must be carefull)
** In case needed url -k https://<VirtualServerIP>/gestion/delete/llt remove all subtable entries

