//================== Stage 4: Driver ==================
`ifndef IPV4_DRIVER_SV
`define IPV4_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_packet.sv"
`include "ipv4_if.sv"

class ipv4_driver extends uvm_driver #(ipv4_packet);
  `uvm_component_utils(ipv4_driver)

  virtual ipv4_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ipv4_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  virtual task run_phase(uvm_phase phase);
    ipv4_packet pkt;
    forever begin
      seq_item_port.get_next_item(pkt);
      `uvm_info("DRV", "Driving packet to DUT", UVM_HIGH)

      // Drive standard fields
      vif.version         = pkt.version;
      vif.ihl             = pkt.ihl;
      vif.dscp            = pkt.dscp;
      vif.ecn             = pkt.ecn;
      vif.total_length    = pkt.total_length;
      vif.identification  = pkt.identification;
      vif.flags           = pkt.flags;
      vif.fragment_offset = pkt.fragment_offset;
      vif.ttl             = pkt.ttl;
      vif.protocol        = pkt.protocol;
      vif.header_checksum = pkt.header_checksum;
      vif.src_ip          = pkt.src_ip;
      vif.dst_ip          = pkt.dst_ip;

      // Drive options
      for (int i = 0; i < 10; i++) vif.options[i] = '0;
      if (pkt.has_options) begin
        foreach (pkt.options[i])
          vif.options[i] = pkt.options[i];
      end

      #1ns;
      vif.valid = 1;
      #10ns;
      vif.valid = 0;
      seq_item_port.item_done();
    end
  endtask

endclass

`endif // IPV4_DRIVER_SV
