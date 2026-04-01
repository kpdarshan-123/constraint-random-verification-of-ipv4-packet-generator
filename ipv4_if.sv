//================== Stage 1: UVM Interface ==================
`ifndef IPV4_IF_SV
`define IPV4_IF_SV

interface ipv4_if();
  // Standard Header Fields
  logic [3:0]  version;
  logic [3:0]  ihl;
  logic [5:0]  dscp;
  logic [1:0]  ecn;
  logic [15:0] total_length;
  logic [15:0] identification;
  logic [2:0]  flags;
  logic [12:0] fragment_offset;
  logic [7:0]  ttl;
  logic [7:0]  protocol;
  logic [15:0] header_checksum;
  logic [31:0] src_ip;
  logic [31:0] dst_ip;

  // Optional Fields
  logic [31:0] options[10]; // Max 10 options (40 bytes)
  logic [7:0]  padding;     // 0-3 bytes padding

  logic        valid;
endinterface

`endif // IPV4_IF_SV
