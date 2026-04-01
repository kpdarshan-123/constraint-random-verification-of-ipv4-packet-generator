//================== Stage 8: Environment ==================
`ifndef IPV4_ENV_SV
`define IPV4_ENV_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_agent.sv"
`include "ipv4_scoreboard.sv"

class ipv4_env extends uvm_env;
  `uvm_component_utils(ipv4_env)

  ipv4_agent      agent;
  ipv4_scoreboard sb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = ipv4_agent::type_id::create("agent", this);
    sb    = ipv4_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    agent.mon.analysis_port.connect(sb.analysis_export);
  endfunction

endclass

`endif // IPV4_ENV_SV
