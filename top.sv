//================== Stage 11: Top Module ==================
`include "uvm_macros.svh"
import uvm_pkg::*;

`include "ipv4_if.sv"
`include "dut.sv"
`include "ipv4_test.sv"

module top;

  ipv4_if vif();
  dut d1(.vif(vif));

  initial begin
    uvm_config_db#(virtual ipv4_if)::set(null, "*", "vif", vif);
    run_test("ipv4_test");
  end

endmodule
