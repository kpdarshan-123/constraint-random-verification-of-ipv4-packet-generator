# Constraint Random Verification of IPv4 Packet Generator

A **Universal Verification Methodology (UVM)** based testbench for verifying an IPv4 packet generator using SystemVerilog constraint random verification techniques.

## Project Overview

This project implements a complete UVM verification environment for an IPv4 packet generator. It generates constrained random IPv4 packets, drives them through a virtual interface, monitors and checks them via a scoreboard, and tracks functional coverage.

## File Structure

```
ipv4_uvm/
├── ipv4_if.sv          # Stage 1  – UVM Interface
├── ipv4_packet.sv      # Stage 2  – Transaction Class (constraints + covergroup)
├── ipv4_sequence.sv    # Stage 3  – Sequence
├── ipv4_driver.sv      # Stage 4  – Driver
├── ipv4_monitor.sv     # Stage 5  – Monitor
├── ipv4_scoreboard.sv  # Stage 6  – Scoreboard
├── ipv4_agent.sv       # Stage 7  – Agent
├── ipv4_env.sv         # Stage 8  – Environment
├── ipv4_test.sv        # Stage 9  – Test
├── dut.sv              # Stage 10 – DUT (with SVA assertions)
└── top.sv              # Stage 11 – Top Module
```

## Features

### Constrained Random Stimulus
- **Version**: Always 4 (IPv4)
- **IHL**: 5–15 (valid range)
- **Protocol**: ICMP (1), TCP (6), UDP (17)
- **TTL**: Non-zero random value
- **Payload Size**: 1–1500 bytes (MTU range)
- **Options**: Dynamic array, up to `IHL - 5` words
- **Fragmentation**: Weighted distribution (90% unfragmented)
- **Checksum Error Injection**: 10% probability for negative testing

### Functional Coverage
| Coverpoint | Description |
|---|---|
| `cp_version` | IPv4 version = 4 |
| `cp_ihl` | Minimal / medium / max header |
| `cp_protocol` | ICMP / TCP / UDP / other |
| `cp_ttl` | Low / mid / high TTL |
| `cp_options` | With and without options |
| `cp_src_ip_class` | Class A–E source IP |
| `cp_dst_ip_class` | Class A–E destination IP |
| `cp_fragmentation` | Fragmented vs unfragmented |
| `proto_x_ttl` | Cross: Protocol × TTL |
| `frag_x_options` | Cross: Fragmentation × Options |

### Scoreboard Checks
- Header length consistency (`total_length == IHL×4 + payload_size`)
- RFC-correct IPv4 header checksum (ones'-complement verification)

### DUT Assertions (SVA)
- Version must equal 4 on every valid pulse
- IHL must be in range `[5:15]` on every valid pulse

## Test Scenarios

| Test Phase | Description |
|---|---|
| Normal Packets | 20 random packets with no constraints overridden |
| With Options | 20 packets forced to include IP options (`has_options == 1`) |
| Fragmented | 20 packets forced to be fragmented (`is_fragmented == 1`) |

## How to Run

### EDA Playground (online)
1. Paste `top.sv` as the top file and add all other `.sv` files.
2. Select **SystemVerilog** + **UVM** and choose your simulator (e.g., Cadence Xcelium or Synopsys VCS).
3. Set top module to `top` and run.

### Cadence Xcelium (local)
```bash
xrun -sv -uvm top.sv ipv4_if.sv ipv4_packet.sv ipv4_sequence.sv \
     ipv4_driver.sv ipv4_monitor.sv ipv4_scoreboard.sv \
     ipv4_agent.sv ipv4_env.sv ipv4_test.sv dut.sv \
     +UVM_TESTNAME=ipv4_test
```

### Synopsys VCS (local)
```bash
vcs -sverilog -ntb_opts uvm top.sv ipv4_if.sv ipv4_packet.sv ipv4_sequence.sv \
    ipv4_driver.sv ipv4_monitor.sv ipv4_scoreboard.sv \
    ipv4_agent.sv ipv4_env.sv ipv4_test.sv dut.sv \
    +UVM_TESTNAME=ipv4_test
./simv +UVM_TESTNAME=ipv4_test
```

## Technologies Used
- **Language**: SystemVerilog
- **Methodology**: UVM (Universal Verification Methodology)
- **Coverage**: Functional coverage with cross-coverage
- **Verification Techniques**: Constraint random verification, scoreboard-based checking, SVA assertions
