//================== Stage 6: Scoreboard ==================
`ifndef IPV4_SCOREBOARD_SV
`define IPV4_SCOREBOARD_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "ipv4_packet.sv"

class ipv4_scoreboard extends uvm_component;
  `uvm_component_utils(ipv4_scoreboard)

  uvm_analysis_imp #(ipv4_packet, ipv4_scoreboard) analysis_export;

  int         packet_count = 0;
  ipv4_packet coverage_pkt;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
    coverage_pkt = ipv4_packet::type_id::create("coverage_pkt");
  endfunction

  virtual function void write(ipv4_packet pkt);
    bit [15:0] calc_csum;
    packet_count++;

    // Verify total length
    if (pkt.total_length != (pkt.ihl * 4 + pkt.payload_size))
      `uvm_error("SCB", $sformatf(
        "Length mismatch: IHL=%0d CalcHdrLen=%0d TotalLen=%0d (Packet %0d)",
        pkt.ihl, (pkt.ihl * 4), pkt.total_length, packet_count))

    // Verify checksum
    calc_csum = pkt.calculate_checksum();
    if (calc_csum != pkt.header_checksum)
      `uvm_error("SCB", $sformatf(
        "Checksum mismatch: Calculated=0x%0h Actual=0x%0h (Packet %0d)",
        calc_csum, pkt.header_checksum, packet_count))
    else
      `uvm_info("SCB", $sformatf(
        "Checksum PASSED for Packet %0d (Checksum: 0x%0h)",
        packet_count, pkt.header_checksum), UVM_LOW)

    // Update coverage
    coverage_pkt.copy(pkt);
    coverage_pkt.ipv4_cg.sample();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("COV", "=== IPv4 Coverage Report ===", UVM_LOW)
    `uvm_info("COV", $sformatf("Total Coverage:                    %.2f%%",
              coverage_pkt.ipv4_cg.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Version Coverage:                  %.2f%%",
              coverage_pkt.ipv4_cg.cp_version.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("IHL Coverage:                      %.2f%%",
              coverage_pkt.ipv4_cg.cp_ihl.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Protocol Coverage:                 %.2f%%",
              coverage_pkt.ipv4_cg.cp_protocol.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("TTL Coverage:                      %.2f%%",
              coverage_pkt.ipv4_cg.cp_ttl.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Options Coverage:                  %.2f%%",
              coverage_pkt.ipv4_cg.cp_options.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Fragmentation Coverage:            %.2f%%",
              coverage_pkt.ipv4_cg.cp_fragmentation.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Protocol x TTL Cross Coverage:     %.2f%%",
              coverage_pkt.ipv4_cg.proto_x_ttl.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Frag x Options Cross Coverage:     %.2f%%",
              coverage_pkt.ipv4_cg.frag_x_options.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Source IP Class Coverage:          %.2f%%",
              coverage_pkt.ipv4_cg.cp_src_ip_class.get_coverage()), UVM_LOW)
    `uvm_info("COV", $sformatf("Destination IP Class Coverage:     %.2f%%",
              coverage_pkt.ipv4_cg.cp_dst_ip_class.get_coverage()), UVM_LOW)
    `uvm_info("COV", "=================================", UVM_LOW)
  endfunction

endclass

`endif // IPV4_SCOREBOARD_SV
