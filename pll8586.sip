set_global_assignment -entity "pll8586" -library "lib_pll8586" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll8586" -library "lib_pll8586" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "pll8586" -library "lib_pll8586" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll8586" -name SPD_FILE [file join $::quartus(sip_path) "pll8586.spd"]

set_global_assignment -library "lib_pll8586" -name MISC_FILE [file join $::quartus(sip_path) "pll8586_sim/pll8586.vo"]
