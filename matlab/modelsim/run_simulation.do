# Create a work library
vlib work

# Compile all Verilog files
vlog image_watermarking_system.v
vlog testbench.v

# Start the simulation, enabling access to signals for debugging
# The +acc flag is needed to allow the testbench to access internal memories
vsim -voptargs=+acc work.testbench

# Optional: Add signals to the wave window for debugging
add wave -position insertpoint sim:/testbench/dut/*

# Run the simulation until it finishes
run -all

# Quit ModelSim
quit -f
