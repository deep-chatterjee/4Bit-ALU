DESIGN = alu_4bit.v
TB = alu_4bit_tb.v
OUTPUT = alu_4bit.vvp
VCD = alu_4bit.vcd

all: sim

compile:
	iverilog -g2012 -o $(OUTPUT) $(DESIGN) $(TB)

sim: compile
	vvp $(OUTPUT)

wave: $(VCD)
	gtkwave $(VCD) &

clean:
	rm -f $(OUTPUT) $(VCD)

.PHONY: all compile sim wave clean
