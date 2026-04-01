//================== Stage 7: Agent ==================
`ifndef IPV4_AGENT_SV
`define IPV4_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_packet.sv"
`include "ipv4_driver.sv"
`include "ipv4_monitor.sv"

class ipv4_agent extends uvm_agent;
  `uvm_component_utils(ipv4_agent)

  ipv4_driver                   drv;
  ipv4_monitor                  mon;
  uvm_sequencer #(ipv4_packet)  seqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = ipv4_driver::type_id::create("drv", this);
    mon  = ipv4_monitor::type_id::create("mon", this);
    seqr = uvm_sequencer#(ipv4_packet)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass

`endif // IPV4_AGENT_SV
