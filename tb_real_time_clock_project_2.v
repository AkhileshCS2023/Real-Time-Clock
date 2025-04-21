`timescale 1ns / 1ps

module tb_rtc;

  // Clock and reset
  reg clk;
  reg reset;

  // BCD outputs from rtc_top
  wire [3:0] HR_M, HR_L;
  wire [3:0] MIN_M, MIN_L;
  wire [3:0] SEC_M, SEC_L;

  // 7?segment outputs
  wire [6:0] seg_hr_m, seg_hr_l;
  wire [6:0] seg_min_m, seg_min_l;
  wire [6:0] seg_sec_m, seg_sec_l;

  // Instantiate the RTC
  rtc_top dut (
    .clk   (clk),
    .reset (reset),
    .HR_M  (HR_M),
    .HR_L  (HR_L),
    .MIN_M (MIN_M),
    .MIN_L (MIN_L),
    .SEC_M (SEC_M),
    .SEC_L (SEC_L)
  );

  // Instantiate BCD?to?7?segment decoders
  bcd_to_7seg dec_hr_m (.bcd(HR_M),  .seg(seg_hr_m));
  bcd_to_7seg dec_hr_l (.bcd(HR_L),  .seg(seg_hr_l));
  bcd_to_7seg dec_min_m(.bcd(MIN_M), .seg(seg_min_m));
  bcd_to_7seg dec_min_l(.bcd(MIN_L), .seg(seg_min_l));
  bcd_to_7seg dec_sec_m(.bcd(SEC_M), .seg(seg_sec_m));
  bcd_to_7seg dec_sec_l(.bcd(SEC_L), .seg(seg_sec_l));

  // 1 Hz clock: toggle every 0.5 s = 500 000 000 ns
  initial clk = 0;
  always #500_000_000 clk = ~clk;

  // Reset and run for N seconds by counting clock edges
  initial begin
    reset = 1;
    // Wait two rising edges to ensure reset spans >1 cycle
    @(posedge clk);
    @(posedge clk);
    reset = 0;

    // Run for 100 seconds (count 100 rising edges of clk)
    repeat (86400)@(posedge clk);

    $finish;
  end

  // Console Monitor
  initial begin
    $monitor("Time = %0t | %d%d:%d%d:%d%d",
             $time, HR_M, HR_L, MIN_M, MIN_L, SEC_M, SEC_L);
  end

endmodule

// -----------------------------
// BCD to 7?Segment Decoder Module
// -----------------------------
module bcd_to_7seg (
    input  [3:0] bcd,
    output reg [6:0] seg
);
always @(*) begin
    case (bcd)
        4'd0: seg = 7'b1111110;
        4'd1: seg = 7'b0110000;
        4'd2: seg = 7'b1101101;
        4'd3: seg = 7'b1111001;
        4'd4: seg = 7'b0110011;
        4'd5: seg = 7'b1011011;
        4'd6: seg = 7'b1011111;
        4'd7: seg = 7'b1110000;
        4'd8: seg = 7'b1111111;
        4'd9: seg = 7'b1111011;
        default: seg = 7'b0000000;
    endcase
end
endmodule

