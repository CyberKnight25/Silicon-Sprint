# Power-Aware INT8 Systolic Array Accelerator



## 📌 Overview
This repository contains a highly optimized, sparsity-aware 4x4 INT8 Systolic Array designed specifically to minimize dynamic power consumption during matrix multiplication workloads. 

Unlike standard matrix multipliers, this architecture explicitly attacks both combinational toggling and sequential clock-tree power waste. It features real-time, hardware-level performance monitoring and is fully verified for synthesis and power extraction in EDA tools like Cadence Genus.

##  Architectural Innovations

To maximize power efficiency, this design implements aggressive RTL-level gating techniques at both the micro and macro levels:

* **Operand Isolation (Combinational Power Saver):** Each Processing Element (PE) continuously monitors incoming data. If a zero is detected on either the activation or weight input, the PE triggers a `skip_mac` flag and clamps the inputs to the combinational multiplier to absolute zero. This physically prevents the internal logic gates from toggling, completely eliminating wasted active power.
* **Integrated Clock Gating / ICG (Sequential Power Saver):** The PE is split into two clock domains. The data-forwarding registers run on a continuous clock to maintain the systolic wavefront. However, the heavy MAC accumulator registers are placed behind a glitch-free Integrated Clock Gating latch. When sparse data enters, the clock signal to the accumulator flatlines, cutting sequential power to zero.
* **Global Sleep Mode (Macro Power Saver):** The top-level module includes a master `global_en` switch. When the array finishes its workload, this switch disables the master clock gate, putting all 16 PEs into a deep sleep state to prevent power drain between workloads.
* **Global Performance Monitor:** The design does not just save power; it proves it. A centralized hardware monitor aggregates the `skip_flag` and `reuse_flag` signals from all 16 PEs. It tracks exact zero-skips and temporal reuses in real-time, outputting the totals to `global_skip_count` and `global_reuse_count` registers.

## 📂 Repository Structure

* `pe.v` - The core Processing Element featuring Operand Isolation and safe synchronous-reset ICG.
* `systolic_4x4.v` - The top-level structural mesh connecting 16 PEs, the master clock gate, and the Global Performance Monitor.
* `pe_tb.v` - The dual-phase testbench that injects a staggered diagonal data wavefront.
* `systolic_power_activity.vcd` - The generated Value Change Dump (VCD) file containing the exact switching activity of the hardware during dense and sparse workloads. 

##  Verification & Synthesis

The testbench is designed to simulate a real-world SoC memory bus, pushing dense matrices followed by high-sparsity matrices. During verification, the array successfully executed mathematical operations with 100% accuracy while dynamically logging hundreds of clock-gated zero-skips during the sparse phase. 

The resulting `.vcd` file is Cadence-ready. By feeding this switching activity history into a synthesis tool, it proves a massive drop in dynamic power when the workload shifts from active to idle.
