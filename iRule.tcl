when ACCESS_POLICY_AGENT_EVENT {
  if { [ACCESS::policy agent_id] eq "lastLogonTime" } {
    set last_login_time [clock format [clock seconds] -format "%Y-%m-%d %H:%M"]
    set username [ACCESS::session data get session.logon.last.username]
    set previous_login_time [table lookup -subtable llt $username]

    # Store the previous login time in an APM session variable
    if { $previous_login_time ne ""} then {
        ACCESS::session data set session.custom.previousLastLogon $previous_login_time
    } else {
        ACCESS::session data set session.custom.previousLastLogon "Desconocido"
    }
    
    # Store the last login time in the table
    table set -subtable llt $username $last_login_time "indef" "indef"
  }
}
