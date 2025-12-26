# Create a work library if it doesn't exist
if {[file exists work]} {
    # Do nothing
} else {
    vlib work
}

# Compile all Verilog files for the extractor
vlog watermark_extractor_system.v
vlog testbench_extractor.v

# Start the simulation
# The +acc flag allows access to internal signals for debugging
vsim -voptargs=+acc work.testbench_extractor

# Optional: Add signals to the wave window
add wave -position insertpoint sim:/testbench_extractor/dut/*

# Run the simulation until it finishes
run -all

# Quit ModelSim
quit -f