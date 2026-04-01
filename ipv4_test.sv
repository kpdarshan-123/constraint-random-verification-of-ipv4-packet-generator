//================== Stage 9: Test ==================
`ifndef IPV4_TEST_SV
`define IPV4_TEST_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_env.sv"
`include "ipv4_sequence.sv"

class ipv4_test extends uvm_test;
  `uvm_component_utils(ipv4_test)

  ipv4_env env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = ipv4_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    ipv4_sequence seq;
    phase.raise_objection(this);

    `uvm_info("TEST", "Starting IPv4 Test with Coverage Tracking", UVM_LOW)

    // Test 1: Normal packets
    `uvm_info("TEST", "=== Testing Normal Packets ===", UVM_LOW)
    seq = ipv4_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);

    // Test 2: Packets with options
    `uvm_info("TEST", "=== Testing Packets with Options ===", UVM_LOW)
    seq = ipv4_sequence::type_id::create("seq");
    seq.test_options = 1;
    seq.start(env.agent.seqr);

    // Test 3: Fragmented packets
    `uvm_info("TEST", "=== Testing Fragmented Packets ===", UVM_LOW)
    seq = ipv4_sequence::type_id::create("seq");
    seq.test_fragmentation = 1;
    seq.start(env.agent.seqr);

    phase.drop_objection(this);
  endtask

endclass

`endif // IPV4_TEST_SV
