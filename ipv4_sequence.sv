//================== Stage 3: Sequence ==================
`ifndef IPV4_SEQUENCE_SV
`define IPV4_SEQUENCE_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_packet.sv"

class ipv4_sequence extends uvm_sequence #(ipv4_packet);
  `uvm_object_utils(ipv4_sequence)

  bit test_options      = 0;
  bit test_fragmentation = 0;

  function new(string name = "ipv4_sequence");
    super.new(name);
  endfunction

  task body();
    ipv4_packet pkt;
    repeat (20) begin
      `uvm_do_with(pkt, {
        if (test_options)       has_options   == 1;
        if (test_fragmentation) is_fragmented == 1;
      })
    end
  endtask

endclass

`endif // IPV4_SEQUENCE_SV
