set_global_assignment -entity "pll65" -library "lib_pll65" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll65" -library "lib_pll65" -name IP_TOOL_VERSION "22.1"
set_global_assignment -entity "pll65" -library "lib_pll65" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll65" -name SPD_FILE [file join $::quartus(sip_path) "pll65.spd"]

set_global_assignment -library "lib_pll65" -name MISC_FILE [file join $::quartus(sip_path) "pll65_sim/pll65.vo"]
