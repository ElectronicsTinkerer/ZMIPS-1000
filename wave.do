onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider VGA_TB
add wave -noupdate -format Logic :tb_vga_core:clk
add wave -noupdate -format Logic :tb_vga_core:v_sync
add wave -noupdate -format Logic :tb_vga_core:h_sync
add wave -noupdate -format Logic :tb_vga_core:avr
add wave -noupdate -format Literal :tb_vga_core:line_num
add wave -noupdate -format Literal :tb_vga_core:pixel_num
add wave -noupdate -divider VGA_CORE
add wave -noupdate -format Logic :tb_vga_core:VGAG0:h_sync
add wave -noupdate -format Logic :tb_vga_core:VGAG0:v_sync
add wave -noupdate -format Logic :tb_vga_core:VGAG0:avr
add wave -noupdate -format Literal :tb_vga_core:VGAG0:line_num
add wave -noupdate -format Literal :tb_vga_core:VGAG0:pixel_num
add wave -noupdate -format Logic :tb_vga_core:VGAG0:clk
add wave -noupdate -format Logic :tb_vga_core:VGAG0:h_detect_fporch
add wave -noupdate -format Logic :tb_vga_core:VGAG0:h_detect_sync
add wave -noupdate -format Logic :tb_vga_core:VGAG0:h_detect_bporch
add wave -noupdate -format Logic :tb_vga_core:VGAG0:h_detect_end
add wave -noupdate -format Logic :tb_vga_core:VGAG0:v_detect_fporch
add wave -noupdate -format Logic :tb_vga_core:VGAG0:v_detect_sync
add wave -noupdate -format Logic :tb_vga_core:VGAG0:v_detect_bporch
add wave -noupdate -format Logic :tb_vga_core:VGAG0:v_detect_end
add wave -noupdate -format Literal :tb_vga_core:VGAG0:pxl
add wave -noupdate -format Literal :tb_vga_core:VGAG0:line
add wave -noupdate -format Literal :tb_vga_core:VGAG0:state_p_pxl
add wave -noupdate -format Literal :tb_vga_core:VGAG0:state_p_line
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
configure wave -namecolwidth 318
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {9068 fs}
