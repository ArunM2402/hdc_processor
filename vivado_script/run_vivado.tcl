# TCL script: run_sim.tcl

#open_project "/home/arunp24/RISCHD/vivado/ri5cy/ri5cy.xpr"
#bram names to be added
# 3 Fixed BRAMs (assuming instance names are known)
#set_property CONFIG.Coe_File {/home/arunp24/RISCHD/csv_files/mnist/temp/X_val_coe_files/row_2.coe} [get_ips blk_mem_gen_4]
#generate_target all [get_files  {{/home/arunp24/RISCHD/vivado/ri5cy/ri5cy.srcs/sources_1/ip/blk_mem_gen_4/blk_mem_gen_4.xci}}]

#catch { config_ip_cache -export [get_ips -all blk_mem_gen_4] }
#export_ip_user_files -of_objects [get_files {{/home/arunp24/RISCHD/vivado/ri5cy/ri5cy.srcs/sources_1/ip/blk_mem_gen_4/blk_mem_gen_4.xci}}]-no_script -sync -force -quiet
#launch_runs blk_mem_gen_3_synth_1
#reset_run blk_mem_gen_4_synth_1
# Launch simulation
#launch_simulation
#run all

# Output simulation result
#write list "$output_file"

#close_sim
#close_project

open_project "/home/arunp24/RISCHD/vivado/ri5cy/ri5cy.xpr"

# Reset and unlock the IP to allow reconfiguration
reset_target all [get_ips blk_mem_gen_4]
upgrade_ip [get_ips blk_mem_gen_4]

# ⚠️ DO NOT set GENERATE_SYNTH_CHECKPOINT – it's optional and breaks when no file is found

# Set updated COE file for memory initialization
set_property CONFIG.Coe_File {<COE_PATH>} [get_ips blk_mem_gen_4]

# Re-generate the target for IP
generate_target all [get_ips blk_mem_gen_4]

# Sync generated IP files
catch { config_ip_cache -export [get_ips -all blk_mem_gen_4] }
export_ip_user_files -of_objects [get_ips blk_mem_gen_4] -no_script -sync -force -quiet
update_compile_order -fileset sources_1

# Launch behavioral simulation
launch_simulation
run all
close_sim
close_project
exit





