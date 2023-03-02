//**************************************************************************
//
//  The content of this file is R&D Center "ELVEES", OJSC proprietary and confidential
//  Copyright (C) 2014 R&D Center "ELVEES", OJSC.
//
//**************************************************************************
//
// Memory configuration information:
//    memname:  hcmos8d_sp_0128x08m16
//    compiler: hcmos8d_sp
//    revision: 0.01
//    bitcells: cell
//
//
//    date:     Fri Feb 21 04:06:55 MSK 2014
//
//**************************************************************************
// =============================================================================
// FILE NAME       : hcmos8d_sp_0128x08m16.v
// -----------------------------------------------------------------------------
// DESCRIPTION     : verilog behavioral model of hcmos8d_sp_0128x08m16
//                   embedded Single Port SRAM module
// -----------------------------------------------------------------------------
// AUTHOR          :
// -----------------------------------------------------------------------------
// VERSION         : 1.02
// =============================================================================
// RELEASE HISTORY :
// -----------------------------------------------------------------------------
// VERSION  DATE(Y-M-D)  USERNAME  COMMENTS
// -----------------------------------------------------------------------------
// *.**     ****-**-**   ********  *********************************************
// 1.00     2013-05-29   olegs     Initial version.
// 1.01     2013-06-07   olegs     Added SDF conditions for $period and $width
//                                 timing arcs.
//                                 Added 'X1' clock transition to X-behavior
//                                 group.
// 1.02     2013-06-11   olegs     Added separate path delay (CLK->Q) for write
//                                 cycle, added SDF conditions for path delays.
//                                 Added $period(negedge CLK) timing arc.
// *.**     ****-**-**   ********  *********************************************
// =============================================================================
// PARAMETERS
// -----------------------------------------------------------------------------
// PARAM NAME   RANGE   :  DESCRIPTION                          :  CURRENT
// -----------------------------------------------------------------------------
// word_depth   64-2k   :  Number of words                      :  128
// addr_width    6-11   :  Number of bits in input address bus  :  7
// BITS          4-16   :  Number of bits per word              :  8
// =============================================================================
// INTERFACE DESCRIPTION
// -----------------------------------------------------------------------------
//  Pin         I/O     COMMENTS
// -----------------------------------------------------------------------------
//  Q[7:0]	OUTPUT  Read data bus
//  A[6:0]	INPUT   Address bus
//  CLK         INPUT   Memory system clock
//  D[7:0]	INPUT   Write data bus
//  CEN         INPUT   Chip enable (active low: 0-enable, 1-disable)
//  WEN         INPUT   Write/Read control (0-write, 1-read)
// =============================================================================
// NOTES : Please NOTE the following points before using this RAM model.
//
//       1. Verilog Model for this RAM architecture has been modeled using
//          a combination of behavioral constructs and structural primitives.
//          It has been modeled to obtain an optimum combination of correct
//          functionality, simulation efficiency and accurate timing behavior
//          including memory corruption (x-handling).
//
//       2. The memory is enabled or disabled based on Chip Enable pin state.
//          The memory is active when Chip Enable (CEN) is held low and
//          deschedules all pending transactions when CEN goes high.
//
//       3. The entire memory is corrupted in all the following cases:
//            - Period/Width violation of clock,
//            - undefined clock transitions (0X, 1X or X1),
//            - write cycle with invalid address.
//
//       4. Macro TSCALE can be set to override default timescale defined in
//          memory model by compiler directive in verilog file:
//                            `define TSCALE '`timescale 1ns/1ps'
//          or option string: +define+TSCALE='`timescale 1ns/1ps'
// =============================================================================

`ifdef TSCALE
`TSCALE
`else
`timescale 1ns/1ps
`endif

`celldefine

module hcmos8d_sp_0128x08m16 (
   Q,
   A,
   CEN,
   CLK,
   D,
   WEN
);
   parameter		   BITS = 8;
   parameter		   word_depth = 128;
   parameter		   addr_width = 7;
   parameter		   wordx = {BITS{1'bx}};
   parameter		   word0 = {BITS{1'b0}};
   parameter		   addrx = {addr_width{1'bx}};

   output [7:0] Q;
   input CLK;
   input CEN;
   input WEN;
   input [6:0] A;
   input [7:0] D;

   reg [BITS-1:0]	   mem [word_depth-1:0];

   reg			   NOT_CEN;
   reg			   NOT_WEN;
   reg			   NOT_A0;
   reg			   NOT_A1;
   reg			   NOT_A2;
   reg			   NOT_A3;
   reg			   NOT_A4;
   reg			   NOT_A5;
   reg			   NOT_A6;
   reg [addr_width-1:0]	   NOT_A;
   reg			   NOT_D0;
   reg			   NOT_D1;
   reg			   NOT_D2;
   reg			   NOT_D3;
   reg			   NOT_D4;
   reg			   NOT_D5;
   reg			   NOT_D6;
   reg			   NOT_D7;
   reg [BITS-1:0]	   NOT_D;
   reg			   NOT_CLK_PER;
   reg			   NOT_CLK_MINH;
   reg			   NOT_CLK_MINL;

   reg			   LAST_NOT_CEN;
   reg			   LAST_NOT_WEN;
   reg [addr_width-1:0]	   LAST_NOT_A;
   reg [BITS-1:0]	   LAST_NOT_D;
   reg			   LAST_NOT_CLK_PER;
   reg			   LAST_NOT_CLK_MINH;
   reg			   LAST_NOT_CLK_MINL;

   wire			   clkrise_q;
   wire			   wt_clkrise_q;

   wire [BITS-1:0]	   _Q;
   wire [addr_width-1:0]   _A;
   wire			   _CLK;
   wire			   _CEN;
   wire			   _WEN;

   wire [BITS-1:0]	   _D;
   wire			   re_flag;
   wire			   re_data_flag;
   wire			   clk_flag;

   reg			   LATCHED_CEN;
   reg			   LATCHED_WEN;
   reg [addr_width-1:0]	   LATCHED_A;
   reg [BITS-1:0]	   LATCHED_D;

   reg			   CENi;
   reg			   WENi;
   reg [addr_width-1:0]	   Ai;
   reg [BITS-1:0]	   Di;
   reg [BITS-1:0]	   Qi;
   reg [BITS-1:0]	   LAST_Qi;

   reg			   LAST_CLK;

   task update_notifier_buses;
   begin
      NOT_A = {
               NOT_A6,
               NOT_A5,
               NOT_A4,
               NOT_A3,
               NOT_A2,
               NOT_A1,
               NOT_A0};
      NOT_D = {
               NOT_D7,
               NOT_D6,
               NOT_D5,
               NOT_D4,
               NOT_D3,
               NOT_D2,
               NOT_D1,
               NOT_D0};
   end
   endtask

   task mem_cycle;
   begin
      casez({WENi,CENi})
        2'b10: begin
           read_mem(1,0);
        end
        2'b00: begin
           write_mem(Ai,Di);
           read_mem(0,0);
        end
        2'b?1: ;
        2'b1x: begin
           read_mem(0,1);
        end
        2'bx0: begin
           write_mem_x(Ai);
           read_mem(0,1);
        end
        2'b0x,
        2'bxx: begin
           write_mem_x(Ai);
           read_mem(0,1);
        end
      endcase
   end
   endtask

   task update_last_notifiers;
   begin
      LAST_NOT_A = NOT_A;
      LAST_NOT_D = NOT_D;
      LAST_NOT_WEN = NOT_WEN;
      LAST_NOT_CEN = NOT_CEN;
      LAST_NOT_CLK_PER = NOT_CLK_PER;
      LAST_NOT_CLK_MINH = NOT_CLK_MINH;
      LAST_NOT_CLK_MINL = NOT_CLK_MINL;
   end
   endtask

   task latch_inputs;
   begin
      LATCHED_A = _A ;
      LATCHED_D = _D ;
      LATCHED_WEN = _WEN ;
      LATCHED_CEN = _CEN ;
      LAST_Qi = Qi;
   end
   endtask

   task update_logic;
   begin
      CENi = LATCHED_CEN;
      WENi = LATCHED_WEN;
      Ai = LATCHED_A;
      Di = LATCHED_D;
   end
   endtask

   task x_inputs;
      integer n;
   begin
      for (n=0; n<addr_width; n=n+1)
         begin
            LATCHED_A[n] = (NOT_A[n]!==LAST_NOT_A[n]) ? 1'bx : LATCHED_A[n] ;
         end
      for (n=0; n<BITS; n=n+1)
         begin
            LATCHED_D[n] = (NOT_D[n]!==LAST_NOT_D[n]) ? 1'bx : LATCHED_D[n] ;
         end
      LATCHED_WEN = (NOT_WEN!==LAST_NOT_WEN) ? 1'bx : LATCHED_WEN ;

      LATCHED_CEN = (NOT_CEN!==LAST_NOT_CEN) ? 1'bx : LATCHED_CEN ;
   end
   endtask

   task read_mem;
      input r_wb;
      input xflag;
   begin
      if (r_wb)
         begin
            if (valid_address(Ai))
               begin
                  Qi=mem[Ai];
               end
            else
               begin
                  Qi=wordx;
               end
         end
      else
         begin
            if (xflag)
               begin
                  Qi=wordx;
               end
            else
               begin
                  Qi=Di;
               end
         end
   end
   endtask

   task write_mem;
      input [addr_width-1:0] a;
      input [BITS-1:0] d;
   begin
      casez({valid_address(a)})
        1'b0: x_mem;
        1'b1: mem[a]=d;
      endcase
   end
   endtask

   task write_mem_x;
      input [addr_width-1:0] a;
   begin
      casez({valid_address(a)})
        1'b0: x_mem;
        1'b1: mem[a]=wordx;
      endcase
   end
   endtask

   task x_mem;
      integer n;
   begin
      for (n=0; n<word_depth; n=n+1) mem[n]=word0;
   end
   endtask

   task process_violations;
   begin
      if ((NOT_CLK_PER!==LAST_NOT_CLK_PER) ||
          (NOT_CLK_MINH!==LAST_NOT_CLK_MINH) ||
          (NOT_CLK_MINL!==LAST_NOT_CLK_MINL))
         begin
            if (CENi !== 1'b1)
               begin
                  x_mem;
                  read_mem(0,1);
               end
         end
      else
         begin
            update_notifier_buses;
            x_inputs;
            update_logic;
            mem_cycle;
         end
      update_last_notifiers;
   end
   endtask

   function valid_address;
      input [addr_width-1:0] a;
   begin
      valid_address = (^(a) !== 1'bx);
   end
   endfunction

// -----------------------------------------------------------------------------
   buf (Q[0], _Q[0]);
   buf (Q[1], _Q[1]);
   buf (Q[2], _Q[2]);
   buf (Q[3], _Q[3]);
   buf (Q[4], _Q[4]);
   buf (Q[5], _Q[5]);
   buf (Q[6], _Q[6]);
   buf (Q[7], _Q[7]);
   buf (_D[0], D[0]);
   buf (_D[1], D[1]);
   buf (_D[2], D[2]);
   buf (_D[3], D[3]);
   buf (_D[4], D[4]);
   buf (_D[5], D[5]);
   buf (_D[6], D[6]);
   buf (_D[7], D[7]);
   buf (_A[0], A[0]);
   buf (_A[1], A[1]);
   buf (_A[2], A[2]);
   buf (_A[3], A[3]);
   buf (_A[4], A[4]);
   buf (_A[5], A[5]);
   buf (_A[6], A[6]);
   buf (_CLK, CLK);
   buf (_WEN, WEN);
   buf (_CEN, CEN);

   assign _Q = Qi;
   assign re_flag = !(_CEN);
   assign re_data_flag = !(_CEN || _WEN);
   assign clk_flag = (CENi !== 1'b1);
   assign clkrise_q    = (CENi !== 1'b1) && (WENi !== 1'b0);
   assign wt_clkrise_q = (CENi !== 1'b1) && (WENi !== 1'b1);

   always @(
            NOT_A0 or
            NOT_A1 or
            NOT_A2 or
            NOT_A3 or
            NOT_A4 or
            NOT_A5 or
            NOT_A6 or
            NOT_D0 or
            NOT_D1 or
            NOT_D2 or
            NOT_D3 or
            NOT_D4 or
            NOT_D5 or
            NOT_D6 or
            NOT_D7 or
            NOT_WEN or
            NOT_CEN or
            NOT_CLK_PER or
            NOT_CLK_MINH or
            NOT_CLK_MINL
            )
      begin
         process_violations;
      end

   always @( _CLK )
      begin
         casez({LAST_CLK,_CLK})
           2'b01: begin
              latch_inputs;
              update_logic;
              mem_cycle;
           end

           2'b10,
           2'bx0,
           2'bxx,
           2'b00,
           2'b11: ;

           2'bx1,
           2'b0x,
           2'b1x: begin
              x_mem;
              read_mem(0,1);
           end
         endcase
         LAST_CLK = _CLK;
      end

   initial x_mem;

// -----------------------------------------------------------------------------
   specify
`ifdef MEM_SDF_SETUP
      specparam SDF_SETUP   = `MEM_SDF_SETUP;
`else
      specparam SDF_SETUP   =  0.0;
`endif
`ifdef MEM_SDF_HOLD
      specparam SDF_HOLD    = `MEM_SDF_HOLD;
`else
      specparam SDF_HOLD    =  0.0;
`endif
`ifdef MEM_SDF_CLK2CLK
      specparam SDF_CLK2CLK = `MEM_SDF_CLK2CLK;
`else
      specparam SDF_CLK2CLK =  0.0;
`endif
`ifdef SDF
      specparam SDF_CCS     =  0.0;
`else
      specparam SDF_CCS     =  0.0;
`endif
`ifdef MEM_SDF_CLKP
      specparam SDF_CLKP    = `MEM_SDF_CLKP;
`else
      specparam SDF_CLKP    =  0.0;
`endif
`ifdef MEM_SDF_CLKH
      specparam SDF_CLKH    = `MEM_SDF_CLKH;
`else
      specparam SDF_CLKH    =  0.0;
`endif
`ifdef MEM_SDF_CLKL
      specparam SDF_CLKL    = `MEM_SDF_CLKL;
`else
      specparam SDF_CLKL    =  0.0;
`endif
`ifdef MEM_SDF_DELAY
      specparam SDF_DELAY   = `MEM_SDF_DELAY;
`else
      specparam SDF_DELAY   =  0.0;
`endif
`ifdef MEM_SDF_RETAIN
      specparam SDF_RETAIN  = `MEM_SDF_RETAIN;
`else
      specparam SDF_RETAIN  =  0.0;
`endif
      specparam tch  = SDF_CLKH;
      specparam tcl  = SDF_CLKL;
      specparam tcp  = SDF_CLKP;
      specparam tha  = SDF_HOLD;
      specparam thd  = SDF_HOLD;
      specparam thc  = SDF_HOLD;
      specparam thw  = SDF_HOLD;
      specparam tsa  = SDF_SETUP;
      specparam tsd  = SDF_SETUP;
      specparam tsc  = SDF_SETUP;
      specparam tsw  = SDF_SETUP;
      specparam tc2c = SDF_CLK2CLK;
      specparam tccs = SDF_CCS;
      specparam tcqv = SDF_DELAY;
      specparam tcqx = SDF_RETAIN;
      specparam twtv = SDF_DELAY;
      specparam twtx = SDF_RETAIN;
// -----------------------------------------------------------------------------
      $setuphold(posedge CLK, posedge CEN, tsc,thc, NOT_CEN);
      $setuphold(posedge CLK, negedge CEN, tsc,thc, NOT_CEN);
      $setuphold(posedge CLK &&& re_flag, posedge WEN, tsw,thw, NOT_WEN);
      $setuphold(posedge CLK &&& re_flag, negedge WEN, tsw,thw, NOT_WEN);
      $setuphold(posedge CLK &&& re_flag, posedge A[0], tsa,tha, NOT_A0);
      $setuphold(posedge CLK &&& re_flag, negedge A[0], tsa,tha, NOT_A0);
      $setuphold(posedge CLK &&& re_flag, posedge A[1], tsa,tha, NOT_A1);
      $setuphold(posedge CLK &&& re_flag, negedge A[1], tsa,tha, NOT_A1);
      $setuphold(posedge CLK &&& re_flag, posedge A[2], tsa,tha, NOT_A2);
      $setuphold(posedge CLK &&& re_flag, negedge A[2], tsa,tha, NOT_A2);
      $setuphold(posedge CLK &&& re_flag, posedge A[3], tsa,tha, NOT_A3);
      $setuphold(posedge CLK &&& re_flag, negedge A[3], tsa,tha, NOT_A3);
      $setuphold(posedge CLK &&& re_flag, posedge A[4], tsa,tha, NOT_A4);
      $setuphold(posedge CLK &&& re_flag, negedge A[4], tsa,tha, NOT_A4);
      $setuphold(posedge CLK &&& re_flag, posedge A[5], tsa,tha, NOT_A5);
      $setuphold(posedge CLK &&& re_flag, negedge A[5], tsa,tha, NOT_A5);
      $setuphold(posedge CLK &&& re_flag, posedge A[6], tsa,tha, NOT_A6);
      $setuphold(posedge CLK &&& re_flag, negedge A[6], tsa,tha, NOT_A6);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[0], tsd,thd, NOT_D0);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[0], tsd,thd, NOT_D0);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[1], tsd,thd, NOT_D1);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[1], tsd,thd, NOT_D1);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[2], tsd,thd, NOT_D2);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[2], tsd,thd, NOT_D2);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[3], tsd,thd, NOT_D3);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[3], tsd,thd, NOT_D3);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[4], tsd,thd, NOT_D4);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[4], tsd,thd, NOT_D4);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[5], tsd,thd, NOT_D5);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[5], tsd,thd, NOT_D5);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[6], tsd,thd, NOT_D6);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[6], tsd,thd, NOT_D6);
      $setuphold(posedge CLK &&& re_data_flag, posedge D[7], tsd,thd, NOT_D7);
      $setuphold(posedge CLK &&& re_data_flag, negedge D[7], tsd,thd, NOT_D7);

      $period(posedge CLK &&& clk_flag, tcp,    NOT_CLK_PER);
      $period(negedge CLK &&& clk_flag, tcp,    NOT_CLK_PER);
      $width (posedge CLK &&& clk_flag, tch, 0, NOT_CLK_MINH);
      $width (negedge CLK &&& clk_flag, tcl, 0, NOT_CLK_MINL);

      if(clkrise_q) (posedge CLK => (Q[0]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[1]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[2]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[3]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[4]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[5]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[6]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_q) (posedge CLK => (Q[7]: CLK))=(tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);

      if(wt_clkrise_q) (posedge CLK => (Q[0]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[1]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[2]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[3]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[4]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[5]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[6]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_q) (posedge CLK => (Q[7]: CLK))=(twtv, twtv, twtx, twtv, twtx, twtv);
   endspecify
// -----------------------------------------------------------------------------

endmodule
`endcelldefine
