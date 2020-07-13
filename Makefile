# Makefile to compile and run simulation for the Switch TB
# NOT YET TESTED if it works : start_wave

compile:
	vlog -sv fifo.sv eth_fsm.sv switch2x2.sv pkt_tb_top.sv

run_sim:
	vsim work.pkt_tb_top -voptargs=+acc

start_wave:
	view signals \
		run -all \
		

quit:
	quit -sim

# NOTE ON VIEWING WAVEFORMS DUMPED DURING SIM
# Default waveform dump file: vsim.wlf (Overwritten on each run)
# Open above waveform from File --> Datasets --> sim (current simulation)

DATE:=$(shell date +"Date: "%d-%m-%Y" Time: "%H:%M)

git_update:
	git add .
	git commit -m "$(DATE) : $(m)"
