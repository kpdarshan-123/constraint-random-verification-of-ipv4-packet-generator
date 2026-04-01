//================== Stage 5: Monitor ==================
`ifndef IPV4_MONITOR_SV
`define IPV4_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_packet.sv"
`include "ipv4_if.sv"

class ipv4_monitor extends uvm_monitor;
  `uvm_component_utils(ipv4_monitor)

  virtual ipv4_if vif;
  uvm_analysis_port #(ipv4_packet) analysis_port;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual ipv4_if)::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not found")
  endfunction

  task run_phase(uvm_phase phase);
    ipv4_packet pkt;
    forever begin
      @(posedge vif.valid);
      pkt = ipv4_packet::type_id::create("pkt", this);

      pkt.version         = vif.version;
      pkt.ihl             = vif.ihl;
      pkt.dscp            = vif.dscp;
      pkt.ecn             = vif.ecn;
      pkt.total_length    = vif.total_length;
      pkt.identification  = vif.identification;
      pkt.flags           = vif.flags;
      pkt.fragment_offset = vif.fragment_offset;
      pkt.ttl             = vif.ttl;
      pkt.protocol        = vif.protocol;
      pkt.header_checksum = vif.header_checksum;
      pkt.src_ip          = vif.src_ip;
      pkt.dst_ip          = vif.dst_ip;

      if (vif.ihl > 5) begin
        pkt.has_options = 1;
        pkt.options = new[vif.ihl - 5];
        foreach (pkt.options[i])
          pkt.options[i] = vif.options[i];
      end else begin
        pkt.has_options = 0;
        pkt.options = new[0];
      end

      pkt.is_fragmented = (vif.flags[0] == 1 || vif.fragment_offset > 0);
      pkt.payload_size  = pkt.total_length - (pkt.ihl * 4);

      `uvm_info("MON", "Monitored packet from DUT", UVM_HIGH)
      analysis_port.write(pkt);
    end
  endtask

endclass

`endif // IPV4_MONITOR_SV
