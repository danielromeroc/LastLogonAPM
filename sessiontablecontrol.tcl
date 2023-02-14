when HTTP_REQUEST {
  set APPNAME "subtables";
  
  set luri  [string tolower [HTTP::path]]
  set app   [getfield $luri "/" 2];
  set cmd   [getfield $luri "/" 3];
  set tname [URI::decode [getfield [HTTP::path] "/" 4]];
  set arg1  [URI::decode [getfield [HTTP::path] "/" 5]];
  set arg2  [URI::decode [getfield [HTTP::path] "/" 6]];
  set resp "";
  
  set send_response 1;
  
  if { $app equals $APPNAME } {

    log local0. "Processing application $app...";

    if { $cmd eq "" } { set cmd "edit"; }
    if { $tname eq "file" } { set tname ""; }
    log local0. "INCOMING URI: $luri, app=$app, cmd=$cmd, tname=$tname";

    set TABLENAME_FORM "<FORM method='get' name='export_table_form' action=''>
<TABLE border='0' class='bottom'>
<TBODY><TR>
<TD>Table Name</TD>
<TD><INPUT type='text' id='table_name' value='' /></TD>
<TD><INPUT type='submit' value='Submit' onclick='javascript:return SubmitForm()' /></TD>
</TR>
</TBODY></TABLE>
</FORM>
<SCRIPT language='JavaScript'><!--
var tn = document.getElementById('table_name');
if ( null != tn ) { tn.focus(); }
//-->;</SCRIPT>";
    
    set FILEINPUT_FORM "
<FORM method='post' enctype='multipart/form-data' action='/$APPNAME/import/file'>
<TABLE cellpadding='0' cellspacing='0' border='0' class='bottom'>
  <TBODY><TR><TD>File</TD><TD><INPUT type='file' accept='text/csv' name='filedata' /></TD></TR>
  <TR><TD></TD><TD align='right'><INPUT type='submit' value='Import' /></TD></TR>
</TBODY></TABLE>
</FORM>";

    append resp "
<TITLE>iRule Table Control</TITLE>
<STYLE type='text/css'>
body,td,th { font-family: Tahoma; font-size: 12px; }
.top { background-color: #D0D0D0; }
.bottom { background-color: C0C0C0; }
.tkey { text-align: center; }
.tvalue { font-family: Lucida Console; }
</STYLE>

<SCRIPT language='JavaScript'><!--
function SubmitForm()
{
  var submit = false;
  var value = document.getElementById('table_name');
  if ( null != value )
  {
    if ( '' != value.value )
    {
      document.export_table_form.action = '/${APPNAME}/${cmd}/' + value.value;
      submit = true;
    }
    else
    {
      window.alert('Please Enter a table name');
      value.focus();
    }
  }
  return submit;
}
//-->t;</SCRIPT>

<TABLE border='1' cellpadding='0' cellspacing='0' width='100%' height='100%'>
<TBODY><TR><TD align='center' valign='top' class='top'>
<CENTER><H1 id='toc-hId-1848544459'><A href='/${APPNAME}'>iRule Table Control</A>($cmd)</H1>
<A href='/${APPNAME}/edit/${tname}'>edit</A> |
<A href='/${APPNAME}/export/${tname}'>export</A> |
<A href='/${APPNAME}/import/'>import</A> |
<A href='/${APPNAME}/delete/${tname}'>delete</A><HR /><P>"
      
    
    #------------------------------------------------------------------------
    # Process commands
    #------------------------------------------------------------------------
    switch $cmd {
      
      "edit" {
      #----------------------------------------------------------------------
      # edit
      #----------------------------------------------------------------------
        log local0. "SUBCOMMAND: edit";
        if { $tname eq "" } {
          append resp $TABLENAME_FORM
        } else {
          append resp "<SCRIPT language='JavaScript'><!--
function SubmitInsert()
{
  var submit = false;
  var tname = document.getElementById('table_name');
  var tkey = document.getElementById('table_key');
  var tvalue = document.getElementById('table_value');
  if ( (null != tname) && (null != tkey) && (null != tvalue) )
  {
    if ( '' == tname.value )
    {
      alert('Couldnt find hidden form value for tablename');
      return;
    }
    if ( '' == tkey.value )
    {
      tkey.focus();
      return;
    }
    if ( '' == tvalue.value )
    {
      tvalue.focus();
      return;
    }
    window.location.href = '/${APPNAME}/insertkey/' + tname.value  + '/' + 
      tkey.value + '/' + tvalue.value;
  }
  return submit;
}
//--></SCRIPT>";
          append resp "<INPUT type='hidden' id='table_name' value='${tname}' />\n";
          
          append resp "<TABLE border='1' cellpadding='5' cellspacing='0'>\n";
          append resp "<TBODY><TR><TH colspan='6'>'$tname' Table</TH></TR>\n";
          append resp "<TR><TH>Key</TH><TH>Value</TH><TH>Timeout</TH><TH>Lifetime</TH><TH></TH></TR>\n";
          foreach key [table keys -subtable $tname] {
            append resp "<TR><TD class='tkey'>$key</TD>";
            append resp "<TD class='tvalue'>[table lookup -subtable $tname $key]</TD>";
            append resp "<TD class='tvalue'>[table timeout -subtable $tname $key]</TD>";
            append resp "<TD class='tvalue'>[table lifetime -subtable $tname $key]</TD>";
            append resp "<TD>\[<A href='/${APPNAME}/deletekey/${tname}/${key}'>X</A>\]</TD>";
            append resp "</TR>\n";
          }
          # Add insertion fields
          append resp "<TR><TD class='tkey'><INPUT type='text' id='table_key' value='' /></TD>";
          append resp "<TD class='tvalue'><INPUT type='text' id='table_value' value='' /></TD>";
          append resp "<TD>\[<A href='#' onclick='SubmitInsert();' rel='nofollow noopener noreferrer'>+</A>\]</TD><TD></TD><TD></TD>";
          append resp "</TR></TBODY></TABLE>\n";
          
          append resp "<SCRIPT language='JavaScript'><--
var tkey = document.getElementById('table_key');
if ( null != tkey ) { tkey.focus(); }
//--></SCRIPT>";
        }
      }
      
      "export" {
      #----------------------------------------------------------------------
      # export
      #----------------------------------------------------------------------
        log local0. "SUBCOMMAND: export";
        if { $tname eq "" } {
          append resp $TABLENAME_FORM
        } else {
          set csv "Table,Key,Value\n";
          foreach key [table keys -subtable $tname] {
            append csv "${tname},${key},[table lookup -subtable $tname $key]\n";
          }
          set filename [clock format [clock seconds] -format "%Y%m%d_%H%M%S_${tname}.csv"]
          log local0. "Responding with filename $filename...";
          
          set disp "attachment; filename=${filename}";
          HTTP::respond 200 content $csv "Content-Type" "text/csv" "Content-Disposition" $disp;
          return;
        }
      }
      
      "import" {
      #----------------------------------------------------------------------
      # import
      #----------------------------------------------------------------------
        if { [HTTP::method] eq "GET" } {
          append resp $FILEINPUT_FORM;
        } else {
          append resp "SUBMITTED FILE...";
          if { [HTTP::header exists "Content-Length"] } {
            log local0. "Collecting [HTTP::header Content-Length] bytes...";
            HTTP::collect [HTTP::header "Content-Length"];
            set send_response 0;
          } else {
            log local0. "Content-Length header doesn't exist!";
          }
        }
      }
      
      "delete" {
      #----------------------------------------------------------------------
      # delete
      #----------------------------------------------------------------------
        log local0. "SUBCOMMAND: delete";
        if { $tname eq "" } {
          append resp $TABLENAME_FORM
        } else {
          table delete -subtable $tname -all;
          append resp "</P><H3 id='toc-hId--1096639512'>Subtable $tname successfully deleted</H3>";
        }
      }
      
      "deletekey" {
      #----------------------------------------------------------------------
      # deletekey
      #----------------------------------------------------------------------
        log local0. "SUBCOMMAND: deletekey";
        if { ($tname ne "") && ($arg1 ne "") } {
          log local0. "Deleting subtable $tname key $arg1...";
          table delete -subtable $tname $arg1;
          HTTP::redirect "http://[HTTP::host]/${APPNAME}/edit/${tname}";
          return;
        }
      }
      
      "insertkey" {
      #----------------------------------------------------------------------
      # insertkey
      #----------------------------------------------------------------------
        log local0. "SUBCOMMAND: insert";
        if { ($tname ne "") && ($arg1 ne "") && ($arg2 ne "") } {
          log local0. "Inserting subtable $tname key $arg1...";
          table set -subtable $tname $arg1 $arg2 indefinite indefinite
          HTTP::redirect "http://[HTTP::host]/${APPNAME}/edit/${tname}";
          return;
        }
      }
      
    }
    
    if { $send_response == 1 } {
      append resp "</CENTER></TD></TR></TBODY></TABLE>";
      HTTP::respond 200 content $resp;
    }
  }
}

when HTTP_REQUEST_DATA {
  
  log local0. "HTTP_REQUEST_DATA ->; app $app";
  if { $app eq $APPNAME } {
    switch $cmd {
      "import" {
        set payload [HTTP::payload]

        #------------------------------------------------------------------------
        # Extract Boundary from "Content-Type" header
        #------------------------------------------------------------------------
        set ctype [HTTP::header "Content-Type"];
        set tokens [split $ctype ";"];
        set boundary "";
        foreach {token} $tokens {
          set t2 [split [string trim $token] "="];
          set name [lindex $t2 0];
          set val [lindex $t2 1];
          if { $name eq "boundary" } {
            set boundary $val;
          }
        }
        
        #------------------------------------------------------------------------
        # Process POST data
        #------------------------------------------------------------------------
        set in_boundary 0;
        set in_filedata 0;
        set past_headers 0;
        set process_data 0;
        set num_lines 0;
        if { "" ne $boundary } {
          
          log local0. "Boundary '$boundary'";
          set lines [split [HTTP::payload] "\n"]
          foreach {line} $lines {
            
            set line [string trim $line];
            log local0. "LINE: '$line'";
            
            if { $line contains $boundary } {

              if { $in_boundary == 0 } {
                #----------------------------------------------------------------
                # entering boundary
                #----------------------------------------------------------------
                log local0. "Entering boundary";
                set in_boundary 1;
                set in_filedata 0;
                set past_headers 0;
                set process_data 0;
              } else {
                #----------------------------------------------------------------
                # exiting boundary
                #----------------------------------------------------------------
                log local0. "Exiting boundary";
                set in_boundary 0;
                set in_filedata 0;
                set past_headers 0;
                set process_data 0;
              }
            } else {
              
              #------------------------------------------------------------------
              # in boundary so check for file content
              #------------------------------------------------------------------
              if { ($line starts_with "Content-Disposition: ") &&
                   ($line contains "filedata") } {
                log local0. "In Filedata";
                set in_filedata 1;
                continue;
              } elseif { $line eq "" } {
                log local0. "Exiting headers";
                set past_headers 1;
              }
            }
            
            if { $in_filedata && $process_data } {
              log local0. "Appending line";
              
              if { ($num_lines > 0) && ($line ne "") } {
                #----------------------------------------------------------------
                # Need to parse line and insert into table
                # line is format : Name,Key,Value
                #----------------------------------------------------------------
                set t [getfield $line "," 1];
                set k [getfield $line "," 2];
                set v [getfield $line "," 3] 
                
                if { ($t ne "") && ($k ne "") && ($v ne "") } {
                  log local0. "Adding table '$t' entry '$k' => '$v'";
                  table set -subtable $t $k $v indefinite indefinite
                }
              }
              incr num_lines;
            }
            
            if { $past_headers } {
              log local0. "Begin processing data";
              set process_data 1;
            }
          }
        }
        incr num_lines -2;
        append resp "<H3 id="toc-hId-646170823">Successfully imported $num_lines table records</H3>";
        append resp "";
        HTTP::respond 200 content $resp;
      }
    }
  }
}
