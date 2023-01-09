set_global_assignment -entity "pll_cpu_40" -library "lib_pll_cpu_40" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_cpu_40" -library "lib_pll_cpu_40" -name IP_TOOL_VERSION "22.1"
set_global_assignment -entity "pll_cpu_40" -library "lib_pll_cpu_40" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_cpu_40" -name SPD_FILE [file join $::quartus(sip_path) "pll_cpu_40.spd"]

set_global_assignment -library "lib_pll_cpu_40" -name MISC_FILE [file join $::quartus(sip_path) "pll_cpu_40_sim/pll_cpu_40.vo"]
