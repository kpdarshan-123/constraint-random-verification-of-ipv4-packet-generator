//================== Stage 2: Transaction Class ==================
`ifndef IPV4_PACKET_SV
`define IPV4_PACKET_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class ipv4_packet extends uvm_sequence_item;
  // Standard Fields
  rand bit [3:0]  version;
  rand bit [3:0]  ihl;
  rand bit [5:0]  dscp;
  rand bit [1:0]  ecn;
  rand bit [15:0] total_length;
  rand bit [15:0] identification;
  rand bit [2:0]  flags;
  rand bit [12:0] fragment_offset;
  rand bit [7:0]  ttl;
  rand bit [7:0]  protocol;
  rand bit [15:0] header_checksum;
  rand bit [31:0] src_ip;
  rand bit [31:0] dst_ip;

  // Optional Fields
  rand bit [31:0] options[];
  rand bit [7:0]  padding;

  // Control Fields
  rand bit          has_options;
  rand bit          is_fragmented;
  rand int unsigned payload_size;
  rand bit          introduce_checksum_error;

  // Basic Constraints
  constraint valid_ipv4 {
    version == 4;
    ihl inside {[5:15]};
    total_length == (ihl * 4) + payload_size;
    ttl > 0;
    protocol inside {1, 6, 17}; // ICMP, TCP, UDP
    payload_size inside {[1:1500]};
    introduce_checksum_error dist {1:/10, 0:/90};
  }

  // Option Constraints
  constraint option_constraints {
    has_options == (options.size() > 0);
    options.size() <= (ihl - 5);
    foreach (options[i]) begin
      if (i == 0) options[i][31:24] inside {0, 1, 2, 7};
      soft options[i] == 0;
    end
    padding == ((ihl * 4) - 20 - (options.size() * 4));
  }

  // Fragmentation Constraints
  constraint fragmentation {
    is_fragmented -> (flags[0] == 1 || fragment_offset > 0);
    fragment_offset dist {0:/90, [1:8191]:/10};
  }

  // Covergroup
  covergroup ipv4_cg;
    cp_version: coverpoint version { bins valid_version = {4}; }
    cp_ihl: coverpoint ihl {
      bins minimal_hdr = {5};
      bins medium_hdr  = {[6:14]};
      bins max_hdr     = {15};
    }
    cp_protocol: coverpoint protocol {
      bins icmp  = {1};
      bins tcp   = {6};
      bins udp   = {17};
      bins other = default;
    }
    cp_ttl: coverpoint ttl {
      bins low_ttl  = {[1:64]};
      bins mid_ttl  = {[65:128]};
      bins high_ttl = {[129:255]};
    }
    cp_options: coverpoint has_options {
      bins no_options   = {0};
      bins with_options = {1};
    }
    cp_src_ip_class: coverpoint src_ip[31:24] {
      bins class_a = {[1:126]};
      bins class_b = {[128:191]};
      bins class_c = {[192:223]};
      bins class_d = {[224:239]};
      bins class_e = {[240:255]};
    }
    cp_dst_ip_class: coverpoint dst_ip[31:24] {
      bins class_a = {[1:126]};
      bins class_b = {[128:191]};
      bins class_c = {[192:223]};
      bins class_d = {[224:239]};
      bins class_e = {[240:255]};
    }
    cp_fragmentation: coverpoint is_fragmented {
      bins unfragmented = {0};
      bins fragmented   = {1};
    }
    proto_x_ttl:       cross cp_protocol, cp_ttl;
    frag_x_options:    cross cp_fragmentation, cp_options;
  endgroup

  `uvm_object_utils_begin(ipv4_packet)
    `uvm_field_int(version,                   UVM_ALL_ON)
    `uvm_field_int(ihl,                       UVM_ALL_ON)
    `uvm_field_int(dscp,                      UVM_ALL_ON)
    `uvm_field_int(ecn,                       UVM_ALL_ON)
    `uvm_field_int(total_length,              UVM_ALL_ON)
    `uvm_field_int(identification,            UVM_ALL_ON)
    `uvm_field_int(flags,                     UVM_ALL_ON)
    `uvm_field_int(fragment_offset,           UVM_ALL_ON)
    `uvm_field_int(ttl,                       UVM_ALL_ON)
    `uvm_field_int(protocol,                  UVM_ALL_ON)
    `uvm_field_int(header_checksum,           UVM_ALL_ON)
    `uvm_field_int(src_ip,                    UVM_ALL_ON)
    `uvm_field_int(dst_ip,                    UVM_ALL_ON)
    `uvm_field_array_int(options,             UVM_ALL_ON)
    `uvm_field_int(padding,                   UVM_ALL_ON)
    `uvm_field_int(has_options,               UVM_ALL_ON)
    `uvm_field_int(is_fragmented,             UVM_ALL_ON)
    `uvm_field_int(payload_size,              UVM_ALL_ON)
    `uvm_field_int(introduce_checksum_error,  UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "ipv4_packet");
    super.new(name);
    ipv4_cg = new();
  endfunction

  // ---- Checksum Calculation ----
  function bit [15:0] calculate_checksum();
    bit [31:0] sum = 0;
    bit [7:0]  header_bytes[];
    int        byte_idx = 0;
    int        total_header_bytes = ihl * 4;

    header_bytes = new[total_header_bytes];

    header_bytes[byte_idx++] = {version, ihl};
    header_bytes[byte_idx++] = {dscp, ecn};
    header_bytes[byte_idx++] = total_length[15:8];
    header_bytes[byte_idx++] = total_length[7:0];
    header_bytes[byte_idx++] = identification[15:8];
    header_bytes[byte_idx++] = identification[7:0];
    header_bytes[byte_idx++] = {flags, fragment_offset[12:8]};
    header_bytes[byte_idx++] = fragment_offset[7:0];
    header_bytes[byte_idx++] = ttl;
    header_bytes[byte_idx++] = protocol;
    header_bytes[byte_idx++] = 8'h00; // checksum placeholder
    header_bytes[byte_idx++] = 8'h00;
    header_bytes[byte_idx++] = src_ip[31:24];
    header_bytes[byte_idx++] = src_ip[23:16];
    header_bytes[byte_idx++] = src_ip[15:8];
    header_bytes[byte_idx++] = src_ip[7:0];
    header_bytes[byte_idx++] = dst_ip[31:24];
    header_bytes[byte_idx++] = dst_ip[23:16];
    header_bytes[byte_idx++] = dst_ip[15:8];
    header_bytes[byte_idx++] = dst_ip[7:0];

    if (has_options) begin
      foreach (options[i]) begin
        header_bytes[byte_idx++] = options[i][31:24];
        header_bytes[byte_idx++] = options[i][23:16];
        header_bytes[byte_idx++] = options[i][15:8];
        header_bytes[byte_idx++] = options[i][7:0];
      end
    end

    while (byte_idx < total_header_bytes)
      header_bytes[byte_idx++] = 8'h00;

    sum = 0;
    for (int i = 0; i < total_header_bytes; i += 2) begin
      bit [15:0] word = {header_bytes[i], header_bytes[i+1]};
      sum += word;
      `uvm_info("CHECKSUM_DEBUG",
                $sformatf("Bytes[%0d:%0d] = 0x%02h%02h = 0x%04h, sum = 0x%08h",
                           i, i+1, header_bytes[i], header_bytes[i+1], word, sum),
                UVM_DEBUG)
    end

    while (sum >> 16)
      sum = (sum >> 16) + (sum & 16'hFFFF);

    return ~sum[15:0];
  endfunction

  // ---- Post-Randomize ----
  function void post_randomize();
    header_checksum = calculate_checksum();
    if (introduce_checksum_error) begin
      `uvm_info("PKT_ERROR", "Intentionally corrupting checksum!", UVM_LOW)
      header_checksum = header_checksum ^ 16'h0001;
    end
    ipv4_cg.sample();
  endfunction

  // ---- Display ----
  function void display();
    string options_str = "";
    string format_str;
    string display_string;

    if (has_options) begin
      foreach (options[i])
        options_str = {options_str, $sformatf("%032b ", options[i])};
    end else begin
      options_str = "None";
    end

    format_str = {"IPv4 Packet (Generated - All Binary): \n",
                  "  Version:         %04b\n",
                  "  IHL:             %04b\n",
                  "  DSCP:            %06b\n",
                  "  ECN:             %02b\n",
                  "  Total Length:    %016b\n",
                  "  Identification:  %016b\n",
                  "  Flags:           %03b\n",
                  "  Fragment Offset: %013b\n",
                  "  TTL:             %08b\n",
                  "  Protocol:        %08b\n",
                  "  Header Checksum: %016b\n",
                  "  Source IP:       %032b\n",
                  "  Dest IP:         %032b\n",
                  "  Has Options:     %01b\n",
                  "  Options (32-bit words): %s\n",
                  "  Padding:         %08b (%0d bytes)\n",
                  "  Is Fragmented:   %01b\n",
                  "  Payload Size:    %0d (decimal)\n",
                  "  Checksum Error Injected: %01b\n"};

    display_string = $sformatf(format_str,
      version, ihl, dscp, ecn, total_length, identification,
      flags, fragment_offset, ttl, protocol, header_checksum,
      src_ip, dst_ip, has_options, options_str,
      padding, padding, is_fragmented, payload_size,
      introduce_checksum_error);

    `uvm_info("PKT", display_string, UVM_LOW);
  endfunction

endclass

`endif // IPV4_PACKET_SV
