IVERILOG ?= iverilog
VVP ?= vvp

.PHONY: all test synth clean

all: test

test:
	$(IVERILOG) -g2012 -o alu_sim alu.sv alu_tb.sv
	$(VVP) alu_sim > sim.log
	cat sim.log
	grep -q "ALL TESTS PASSED" sim.log

clean:
	rm -rf alu_sim *.vcd *.log build