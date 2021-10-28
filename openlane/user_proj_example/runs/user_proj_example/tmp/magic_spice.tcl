
if { [info exist ::env(MAGIC_EXT_USE_GDS)] && $::env(MAGIC_EXT_USE_GDS) } {
	gds read $::env(CURRENT_GDS)
} else {
	lef read /soft/ProgramFiles/caravel_user_project/openlane_caravel/pdks/sky130A/libs.ref/sky130_fd_sc_hd/techlef/sky130_fd_sc_hd.tlef
	if {  [info exist ::env(EXTRA_LEFS)] } {
		set lefs_in $::env(EXTRA_LEFS)
		foreach lef_file $lefs_in {
			lef read $lef_file
		}
	}
	def read /project/openlane/user_proj_example/runs/user_proj_example/results/routing/23-user_proj_example.def
}
load user_proj_example -dereference
cd /project/openlane/user_proj_example/runs/user_proj_example/results/magic/
extract do local
extract no capacitance
extract no coupling
extract no resistance
extract no adjust
if { ! 0 } {
	extract unique
}
# extract warn all
extract

ext2spice lvs
ext2spice -o /project/openlane/user_proj_example/runs/user_proj_example/results/magic/user_proj_example.spice user_proj_example.ext
feedback save /project/openlane/user_proj_example/runs/user_proj_example/logs/magic/36-magic_ext2spice.feedback.txt
# exec cp user_proj_example.spice /project/openlane/user_proj_example/runs/user_proj_example/results/magic/user_proj_example.spice

