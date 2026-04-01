//================== Stage 10: DUT ==================
`ifndef DUT_SV
`define DUT_SV

`include "ipv4_if.sv"

module dut(ipv4_if vif);

  // Assertion: IPv4 version must be 4
  assert property (@(posedge vif.valid) vif.version == 4)
    $info("DUT: IPv4 version is 4.");
  else
    $error("DUT: IPv4 version is not 4! (Version: %0d)", vif.version);

  // Assertion: IHL must be in valid range [5:15]
  assert property (@(posedge vif.valid) vif.ihl inside {[5:15]})
    $info("DUT: IPv4 IHL is within valid range.");
  else
    $error("DUT: IPv4 IHL is out of range! (IHL: %0d)", vif.ihl);

  always @(posedge vif.valid) begin
    $display("\n=== IPv4 Header Analysis ===");
    $display("Bits 0-3   (Version):        %04b (%0d)",               vif.version, vif.version);
    $display("Bits 4-7   (IHL):            %04b (%0d words = %0d bytes)", vif.ihl, vif.ihl, vif.ihl*4);
    $display("Bits 8-13  (DSCP):           %06b (%0d)",               vif.dscp,   vif.dscp);
    $display("Bits 14-15 (ECN):            %02b (%0d)",               vif.ecn,    vif.ecn);
    $display("Bits 16-31 (Total Length):   %016b (%0d bytes)",        vif.total_length, vif.total_length);
    $display("Bits 32-47 (Identification): %016b (%0d)",              vif.identification, vif.identification);
    $display("Bits 48-50 (Flags):          %03b",                     vif.flags);
    $display("  - Reserved (bit 0):        %01b",                     vif.flags[2]);
    $display("  - Don't Fragment:          %01b",                     vif.flags[1]);
    $display("  - More Fragments:          %01b",                     vif.flags[0]);
    $display("Bits 51-63 (Frag Offset):    %013b (%0d)",              vif.fragment_offset, vif.fragment_offset);
    $display("Bits 64-71 (TTL):            %08b (%0d)",               vif.ttl,      vif.ttl);
    $display("Bits 72-79 (Protocol):       %08b (%0d)",               vif.protocol, vif.protocol);
    $display("Bits 80-95 (Checksum):       %016b (0x%04h)",           vif.header_checksum, vif.header_checksum);
    $display("Bits 96-127 (Source IP):     %032b (%0d.%0d.%0d.%0d)",
             vif.src_ip,
             (vif.src_ip >> 24) & 8'hFF, (vif.src_ip >> 16) & 8'hFF,
             (vif.src_ip >>  8) & 8'hFF,  vif.src_ip         & 8'hFF);
    $display("Bits 128-159 (Dest IP):      %032b (%0d.%0d.%0d.%0d)",
             vif.dst_ip,
             (vif.dst_ip >> 24) & 8'hFF, (vif.dst_ip >> 16) & 8'hFF,
             (vif.dst_ip >>  8) & 8'hFF,  vif.dst_ip         & 8'hFF);
  end

endmodule

`endif // DUT_SV
