set_global_assignment -entity "pll10800" -library "lib_pll10800" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll10800" -library "lib_pll10800" -name IP_TOOL_VERSION "21.1"
set_global_assignment -entity "pll10800" -library "lib_pll10800" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll10800" -name SPD_FILE [file join $::quartus(sip_path) "pll10800.spd"]

set_global_assignment -library "lib_pll10800" -name MISC_FILE [file join $::quartus(sip_path) "pll10800_sim/pll10800.vo"]
