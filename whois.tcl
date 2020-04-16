##############################################################################################
##  ##     whois.tcl for eggdrop by Ford_Lawnmower irc.geekshed.net #Script-Help        ##  ##
##############################################################################################
## To use this script you must set channel flag +whois (ie .chanset #chan +whois)           ##
##############################################################################################
##      ____                __                 ###########################################  ##
##     / __/___ _ ___ _ ___/ /____ ___   ___   ###########################################  ##
##    / _/ / _ `// _ `// _  // __// _ \ / _ \  ###########################################  ##
##   /___/ \_, / \_, / \_,_//_/   \___// .__/  ###########################################  ##
##        /___/ /___/                 /_/      ###########################################  ##
##                                             ###########################################  ##
##############################################################################################
##  ##                             Start Setup.                                         ##  ##
##############################################################################################
namespace eval whois {
## change cmdchar to the trigger you want to use                                        ##  ##
  variable cmdchar "!"
## change command to the word trigger you would like to use.                            ##  ##
## Keep in mind, This will also change the .chanset +/-command                          ##  ##
  variable command "whois"
## change textf to the colors you want for the text.                                    ##  ##
  variable textf "\017\00304"
## change tagf to the colors you want for tags:                                         ##  ##  
  variable tagf "\017\002"
## Change logo to the logo you want at the start of the line.                           ##  ##  
  variable logo "\017\00304\002\[\00306W\003hois\00304\]\017"
## Change lineout to the results you want. Valid results are channel users modes topic  ##  ##
  variable lineout "channel users modes topic"
##############################################################################################
##  ##                           End Setup.                                              ## ##
##############################################################################################  
  variable channel ""
  setudef flag $whois::command
  bind pub -|- [string trimleft $whois::cmdchar]${whois::command} whois::list
  bind raw -|- "311" whois::311
  bind raw -|- "312" whois::312
  bind raw -|- "319" whois::319
  bind raw -|- "317" whois::317
  bind raw -|- "313" whois::multi
  bind raw -|- "310" whois::multi
  bind raw -|- "335" whois::multi
  bind raw -|- "301" whois::301
  bind raw -|- "671" whois::multi
  bind raw -|- "320" whois::multi
  bind raw -|- "401" whois::multi
  bind raw -|- "318" whois::318
  bind raw -|- "307" whois::307
}
proc whois::311 {from key text} {
  if {[regexp -- {^[^\s]+\s(.+?)\s(.+?)\s(.+?)\s\*\s\:(.+)$} $text wholematch nick ident host realname]} {
    putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Host:${whois::textf} \
    $nick \(${ident}@${host}\) ${whois::tagf}Realname:${whois::textf} $realname"
  }
}
proc whois::multi {from key text} {
  if {[regexp {\:(.*)$} $text match $key]} {
    putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Note:${whois::textf} [subst $$key]"
    return 1
  }
}
proc whois::312 {from key text} {
  regexp {([^\s]+)\s\:} $text match server
  putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Server:${whois::textf} $server"
}
proc whois::319 {from key text} {
  if {[regexp {.+\:(.+)$} $text match channels]} {
    putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Channels:${whois::textf} $channels"
  }
}
proc whois::317 {from key text} {
  if {[regexp -- {.*\s(\d+)\s(\d+)\s\:} $text wholematch idle signon]} {
    putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Connected:${whois::textf} \
    [ctime $signon] ${whois::tagf}Idle:${whois::textf} [duration $idle]"
  }
}
proc whois::301 {from key text} {
  if {[regexp {^.+\s[^\s]+\s\:(.*)$} $text match awaymsg]} {
    putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Away:${whois::textf} $awaymsg"
  }
}
proc whois::318 {from key text} {
  namespace eval whois {
    variable channel ""
  }
  variable whois::channel ""
}
proc whois::307 {from key text} {
  putserv "PRIVMSG $whois::channel :${whois::logo} ${whois::tagf}Services:${whois::textf} Registered Nick"
}
proc whois::list {nick host hand chan text} {
  if {[lsearch -exact [channel info $chan] "+${whois::command}"] != -1} {
    namespace eval whois {
      variable channel ""
    }
    variable whois::channel $chan
    putserv "WHOIS $text"
  }
}
putlog "\002*Loaded* \017\00304\002\[\00306W\003hois\00304\]\017 \002by \
Ford_Lawnmower irc.GeekShed.net #Script-Help" 