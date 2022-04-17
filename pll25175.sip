set_global_assignment -entity "pll25175" -library "lib_pll25175" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll25175" -library "lib_pll25175" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "pll25175" -library "lib_pll25175" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll25175" -name SPD_FILE [file join $::quartus(sip_path) "pll25175.spd"]

set_global_assignment -library "lib_pll25175" -name MISC_FILE [file join $::quartus(sip_path) "pll25175_sim/pll25175.vo"]
