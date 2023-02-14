when ACCESS_POLICY_AGENT_EVENT {
  if { [ACCESS::policy agent_id] eq "lastLogonTime" } {
    set last_login_time [clock format [clock seconds] -format "%Y-%m-%d-%H%M%S"]
    set username [ACCESS::session data get session.logon.last.username]
    set previous_login_time [table lookup -subtable llt $username]

    # Store the previous login time in an APM session variable
    ACCESS::session data set session.custom.previousLastLogon $previous_login_time

    # NO NEED TO (Commented) Remove the previous login time from the table
    # table delete -subtable llt $username

    # Store the last login time in the table
    table set -subtable llt $username $last_login_time "indef" "indef"
  }
}
