# RISC-V Pipelined CPU — Phase 1  
### Computer Architecture Course Project  
**Authors:**  
- Yazan AbuBakir  
  

## 📌 Project Description  
This repository contains of our RISC-V RV32I processor implementation.  
In this phase we built:

- A custom Python RISC-V assembler
- All required Verilog hardware modules
- A working 5-stage pipelined CPU
- Dedicated testbenches for every module  
- They exist only to execute the simulation 

---

### ✔️ **.vcd files (waveform dumps)**  
- Generated while running the `.vvp` simulation  
- Contain timing diagrams and signal transitions  
- Used for visual debugging of the CPU pipeline via GTKWave  
- View using:

- Complete simulation waveforms (.vcd files)  
- A full PDF report describing the design  

This CPU currently doesnot include hazards or forwarding (implemented in Phase 2).

---
---

## 🛠️ Tools & Simulation Environment  

This project uses Icarus Verilog as the primary Verilog compiler and simulator.

### **Icarus Toolchain**
- `iverilog` → Compiles Verilog files into a simulation executable (`.vvp`)
- `vvp` → Runs the compiled simulation
- `gtkwave` → Used to open waveform files (`.vcd`)

We selected Icarus Verilog because it is fast, open-source, and ideal for CPU design projects.

---

## 📡 Understanding `.vcd` and `.vvp` Files  

During simulation, the following files are generated automatically:

### ✔️ **.vvp files (compiled simulation executables)**  
- Produced by the Icarus compiler (`iverilog`)  
- Contain the compiled logic of the testbench + modules  




