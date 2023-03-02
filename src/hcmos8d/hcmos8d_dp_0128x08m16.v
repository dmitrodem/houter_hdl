//**************************************************************************
//
//  The content of this file is R&D Center "ELVEES", OJSC proprietary and confidential
//  Copyright (C) 2014 R&D Center "ELVEES", OJSC.
//
//**************************************************************************
//
// Memory configuration information:
//    memname:  hcmos8d_dp_0128x08m16
//    compiler: hcmos8d_dp
//    revision: 0.01
//    bitcells: cell2
//
//
//    date:     Tue Jul 15 18:14:08 MSK 2014
//
//**************************************************************************
// =============================================================================
// FILE NAME       : hcmos8d_dp_0128x08m16.v
// -----------------------------------------------------------------------------
// DESCRIPTION     : verilog behavioral model of hcmos8d_dp_0128x08m16
//                   embedded Dual Port SRAM module
// -----------------------------------------------------------------------------
// AUTHOR          :
// -----------------------------------------------------------------------------
// VERSION         : 1.03
// =============================================================================
// RELEASE HISTORY :
// -----------------------------------------------------------------------------
// VERSION  DATE(Y-M-D)  USERNAME  COMMENTS
// -----------------------------------------------------------------------------
// *.**     ****-**-**   ********  *********************************************
// 1.00     2013-04-19   olegs     Initial version.
// 1.01     2013-06-07   olegs     Added SDF conditions for $period and $width
//                                 timing arcs.
//                                 Added 'X1' clock transition to X-behavior
//                                 group.
// 1.02     2013-06-11   olegs     Added separate path delay (CLK->Q) for write
//                                 cycle, added SDF conditions for path delays.
//                                 Added $period(negedge CLK) timing arc.
//                                 Added viol_flag to memcycle task.
// 1.03     2013-07-10   olegs     Added invalid adresses to clk2clk collision
//                                 conditions.
// *.**     ****-**-**   ********  *********************************************
// =============================================================================
// PARAMETERS
// -----------------------------------------------------------------------------
// PARAM NAME   RANGE   :  DESCRIPTION                          :  CURRENT
// -----------------------------------------------------------------------------
// word_depth  128-2k   :  Number of words                      :  128
// addr_width    7-11   :  Number of bits in input address bus  :  7
// BITS          4-16   :  Number of bits per word              :  8
// =============================================================================
// INTERFACE DESCRIPTION
// -----------------------------------------------------------------------------
//  Pin         I/O     COMMENTS
// -----------------------------------------------------------------------------
//  QA[7:0]	OUTPUT  Read data bus
//  AA[6:0]	INPUT   Address bus
//  CLKA        INPUT   Memory system clock
//  DA[7:0]	INPUT   Write data bus
//  CENA        INPUT   Chip enable (active low: 0-enable, 1-disable)
//  WENA        INPUT   Write/Read control (0-write, 1-read)
// -----------------------------------------------------------------------------
//  QB[7:0]	OUTPUT  Read data bus
//  AB[6:0]	INPUT   Address bus
//  CLKB        INPUT   Memory system clock
//  DB[7:0]	INPUT   Write data bus
//  CENB        INPUT   Chip enable (active low: 0-enable, 1-disable)
//  WENB        INPUT   Write/Read control (0-write, 1-read)
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
//            - write cycle with invalid address,
//            - both ports write access the same memory location.
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

module hcmos8d_dp_0128x08m16 (
   QA,
   CLKA,
   CENA,
   WENA,
   AA,
   DA,
   QB,
   CLKB,
   CENB,
   WENB,
   AB,
   DB
);
   parameter		   BITS = 8;
   parameter		   word_depth = 128;
   parameter		   addr_width = 7;
   parameter		   wordx = {BITS{1'bx}};
   parameter		   word0 = {BITS{1'b0}};
   parameter		   addrx = {addr_width{1'bx}};

   output [7:0] QA;
   input CLKA;
   input CENA;
   input WENA;
   input [6:0] AA;
   input [7:0] DA;
   output [7:0] QB;
   input CLKB;
   input CENB;
   input WENB;
   input [6:0] AB;
   input [7:0] DB;

   reg [BITS-1:0]	   mem [word_depth-1:0];
   reg			   NOT_CONTA;
   reg			   NOT_CONTB;

   reg			   NOT_CENA;
   reg			   NOT_WENA;
   reg			   NOT_AA0;
   reg			   NOT_AA1;
   reg			   NOT_AA2;
   reg			   NOT_AA3;
   reg			   NOT_AA4;
   reg			   NOT_AA5;
   reg			   NOT_AA6;
   reg [addr_width-1:0]	   NOT_AA;
   reg			   NOT_DA0;
   reg			   NOT_DA1;
   reg			   NOT_DA2;
   reg			   NOT_DA3;
   reg			   NOT_DA4;
   reg			   NOT_DA5;
   reg			   NOT_DA6;
   reg			   NOT_DA7;
   reg [BITS-1:0]	   NOT_DA;
   reg			   NOT_CLKA_PER;
   reg			   NOT_CLKA_MINH;
   reg			   NOT_CLKA_MINL;
   reg			   NOT_CENB;
   reg			   NOT_WENB;
   reg			   NOT_AB0;
   reg			   NOT_AB1;
   reg			   NOT_AB2;
   reg			   NOT_AB3;
   reg			   NOT_AB4;
   reg			   NOT_AB5;
   reg			   NOT_AB6;
   reg [addr_width-1:0]	   NOT_AB;
   reg			   NOT_DB0;
   reg			   NOT_DB1;
   reg			   NOT_DB2;
   reg			   NOT_DB3;
   reg			   NOT_DB4;
   reg			   NOT_DB5;
   reg			   NOT_DB6;
   reg			   NOT_DB7;
   reg [BITS-1:0]	   NOT_DB;
   reg			   NOT_CLKB_PER;
   reg			   NOT_CLKB_MINH;
   reg			   NOT_CLKB_MINL;

   reg			   LAST_NOT_CENA;
   reg			   LAST_NOT_WENA;
   reg [addr_width-1:0]	   LAST_NOT_AA;
   reg [BITS-1:0]	   LAST_NOT_DA;
   reg			   LAST_NOT_CLKA_PER;
   reg			   LAST_NOT_CLKA_MINH;
   reg			   LAST_NOT_CLKA_MINL;
   reg			   LAST_NOT_CENB;
   reg			   LAST_NOT_WENB;
   reg [addr_width-1:0]	   LAST_NOT_AB;
   reg [BITS-1:0]	   LAST_NOT_DB;
   reg			   LAST_NOT_CLKB_PER;
   reg			   LAST_NOT_CLKB_MINH;
   reg			   LAST_NOT_CLKB_MINL;

   reg			   LAST_NOT_CONTA;
   reg			   LAST_NOT_CONTB;
   wire			   contA_flag;
   wire			   contB_flag;
   wire			   cont_flag;

   wire			   clkrise_qa;
   wire			   wt_clkrise_qa;

   wire [BITS-1:0]	   _QA;
   wire [addr_width-1:0]   _AA;
   wire			   _CLKA;
   wire			   _CENA;
   wire			   _WENA;

   wire [BITS-1:0]	   _DA;
   wire			   re_flagA;
   wire			   re_data_flagA;
   wire			   clk_flagA;

   wire			   clkrise_qb;
   wire			   wt_clkrise_qb;

   wire [BITS-1:0]	   _QB;
   wire [addr_width-1:0]   _AB;
   wire			   _CLKB;
   wire			   _CENB;
   wire			   _WENB;

   wire [BITS-1:0]	   _DB;
   wire			   re_flagB;
   wire			   re_data_flagB;
   wire			   clk_flagB;

   reg			   LATCHED_CENA;
   reg			   LATCHED_WENA;
   reg [addr_width-1:0]	   LATCHED_AA;
   reg [BITS-1:0]	   LATCHED_DA;
   reg			   LATCHED_CENB;
   reg			   LATCHED_WENB;
   reg [addr_width-1:0]	   LATCHED_AB;
   reg [BITS-1:0]	   LATCHED_DB;

   reg			   CENAi;
   reg			   WENAi;
   reg [addr_width-1:0]	   AAi;
   reg [BITS-1:0]	   DAi;
   reg [BITS-1:0]	   QAi;
   reg [BITS-1:0]	   LAST_QAi;
   reg			   CENBi;
   reg			   WENBi;
   reg [addr_width-1:0]	   ABi;
   reg [BITS-1:0]	   DBi;
   reg [BITS-1:0]	   QBi;
   reg [BITS-1:0]	   LAST_QBi;

   reg			   LAST_CLKA;
   reg			   LAST_CLKB;

   reg [BITS-1:0]	   LAST_MEMA;
   reg [BITS-1:0]	   LAST_MEMB;

   reg			   valid_cycleA;
   reg			   valid_cycleB;


   task update_Anotifier_buses;
   begin
      NOT_AA = {
               NOT_AA6,
               NOT_AA5,
               NOT_AA4,
               NOT_AA3,
               NOT_AA2,
               NOT_AA1,
               NOT_AA0};
      NOT_DA = {
               NOT_DA7,
               NOT_DA6,
               NOT_DA5,
               NOT_DA4,
               NOT_DA3,
               NOT_DA2,
               NOT_DA1,
               NOT_DA0};
   end
   endtask
   task update_Bnotifier_buses;
   begin
      NOT_AB = {
               NOT_AB6,
               NOT_AB5,
               NOT_AB4,
               NOT_AB3,
               NOT_AB2,
               NOT_AB1,
               NOT_AB0};
      NOT_DB = {
               NOT_DB7,
               NOT_DB6,
               NOT_DB5,
               NOT_DB4,
               NOT_DB3,
               NOT_DB2,
               NOT_DB1,
               NOT_DB0};
   end
   endtask

   task mem_cycleA;
     input viol_flag;
   begin
      valid_cycleA = 1'bx;
      casez({WENAi,CENAi})
        2'b10: begin
           valid_cycleA = 1;
           read_memA(1,0);
        end
        2'b00: begin
           valid_cycleA = 0;
           if (viol_flag) read_violA;
           else read_memA(1,0);
           write_mem(AAi,DAi);
        end
        2'b?1: ;
        2'b1x: begin
           valid_cycleA = 1;
           read_memA(0,1);
        end
        2'bx0: begin
           valid_cycleA = 0;
           write_mem_x(AAi);
           read_memA(0,1);
        end
        2'b0x,
        2'bxx: begin
           valid_cycleA = 0;
           write_mem_x(AAi);
           read_memA(0,1);
        end
      endcase
   end
   endtask

   task mem_cycleB;
     input viol_flag;
   begin
      valid_cycleB = 1'bx;
      casez({WENBi,CENBi})

        2'b10: begin
           valid_cycleB = 1;
           read_memB(1,0);
        end
        2'b00: begin
           valid_cycleB = 0;
           if (viol_flag) read_violB;
           else read_memB(1,0);
           write_mem(ABi,DBi);
        end
        2'b?1: ;
        2'b1x: begin
           valid_cycleB = 1;
           read_memB(0,1);
        end
        2'bx0: begin
           valid_cycleB = 0;
           write_mem_x(ABi);
           read_memB(0,1);
        end
        2'b0x,
        2'bxx: begin
           valid_cycleB = 0;
           write_mem_x(ABi);
           read_memB(0,1);
        end
      endcase
   end
   endtask

   task contentionA;
   begin
      casez({valid_cycleB,WENAi})
        2'bx?: ;
        2'b00,
        2'b0x:begin
           write_mem_x(AAi);
        end
        2'b10,
        2'b1x:begin
           read_memB(0,1);
        end
        2'b01:begin
           read_memA(0,1);
        end
        2'b11: ;
      endcase
   end
   endtask

   task contentionB;
   begin
      casez({valid_cycleA,WENBi})
        2'bx?: ;
        2'b00,
        2'b0x:begin
           write_mem_x(ABi);
        end
        2'b10,
        2'b1x:begin
           read_memA(0,1);
        end
        2'b01:begin
           read_memB(0,1);
        end
        2'b11: ;
      endcase
   end
   endtask

   task update_Alast_notifiers;
   begin
      LAST_NOT_AA = NOT_AA;
      LAST_NOT_DA = NOT_DA;
      LAST_NOT_WENA = NOT_WENA;
      LAST_NOT_CENA = NOT_CENA;
      LAST_NOT_CLKA_PER = NOT_CLKA_PER;
      LAST_NOT_CLKA_MINH = NOT_CLKA_MINH;
      LAST_NOT_CLKA_MINL = NOT_CLKA_MINL;
      LAST_NOT_CONTA = NOT_CONTA;
   end
   endtask
   task update_Blast_notifiers;
   begin
      LAST_NOT_AB = NOT_AB;
      LAST_NOT_DB = NOT_DB;
      LAST_NOT_WENB = NOT_WENB;
      LAST_NOT_CENB = NOT_CENB;
      LAST_NOT_CLKB_PER = NOT_CLKB_PER;
      LAST_NOT_CLKB_MINH = NOT_CLKB_MINH;
      LAST_NOT_CLKB_MINL = NOT_CLKB_MINL;
      LAST_NOT_CONTB = NOT_CONTB;
   end
   endtask

   task latch_Ainputs;
   begin
      LATCHED_AA = _AA ;
      LATCHED_DA = _DA ;
      LATCHED_WENA = _WENA ;
      LATCHED_CENA = _CENA ;
      LAST_QAi = QAi;
      LAST_MEMA = mem[LATCHED_AA];
   end
   endtask
   task latch_Binputs;
   begin
      LATCHED_AB = _AB ;
      LATCHED_DB = _DB ;
      LATCHED_WENB = _WENB ;
      LATCHED_CENB = _CENB ;
      LAST_QBi = QBi;
      LAST_MEMB = mem[LATCHED_AB];
   end
   endtask

   task update_Alogic;
   begin
      CENAi = LATCHED_CENA;
      WENAi = LATCHED_WENA;
      AAi = LATCHED_AA;
      DAi = LATCHED_DA;
   end
   endtask
   task update_Blogic;
   begin
      CENBi = LATCHED_CENB;
      WENBi = LATCHED_WENB;
      ABi = LATCHED_AB;
      DBi = LATCHED_DB;
   end
   endtask

   task x_Ainputs;
      integer n;
   begin
      for (n=0; n<addr_width; n=n+1)
         begin
            LATCHED_AA[n] = (NOT_AA[n]!==LAST_NOT_AA[n]) ? 1'bx : LATCHED_AA[n] ;
         end
      for (n=0; n<BITS; n=n+1)
         begin
            LATCHED_DA[n] = (NOT_DA[n]!==LAST_NOT_DA[n]) ? 1'bx : LATCHED_DA[n] ;
         end
      LATCHED_WENA = (NOT_WENA!==LAST_NOT_WENA) ? 1'bx : LATCHED_WENA ;

      LATCHED_CENA = (NOT_CENA!==LAST_NOT_CENA) ? 1'bx : LATCHED_CENA ;
   end
   endtask
   task x_Binputs;
      integer n;
   begin
      for (n=0; n<addr_width; n=n+1)
         begin
            LATCHED_AB[n] = (NOT_AB[n]!==LAST_NOT_AB[n]) ? 1'bx : LATCHED_AB[n] ;
         end
      for (n=0; n<BITS; n=n+1)
         begin
            LATCHED_DB[n] = (NOT_DB[n]!==LAST_NOT_DB[n]) ? 1'bx : LATCHED_DB[n] ;
         end
      LATCHED_WENB = (NOT_WENB!==LAST_NOT_WENB) ? 1'bx : LATCHED_WENB ;

      LATCHED_CENB = (NOT_CENB!==LAST_NOT_CENB) ? 1'bx : LATCHED_CENB ;
   end
   endtask

   task read_memA;
      input r_wb;
      input xflag;
   begin
      if (r_wb)
         begin
            if (valid_address(AAi))
               begin
                  QAi=mem[AAi];
               end
            else
               begin
                  QAi=wordx;
               end
         end
      else
         begin
            if (xflag)
               begin
                  QAi=wordx;
               end
            else
               begin
                  QAi=DAi;
               end
         end
   end
   endtask
   task read_memB;
      input r_wb;
      input xflag;
   begin
      if (r_wb)
         begin
            if (valid_address(ABi))
               begin
                  QBi=mem[ABi];
               end
            else
               begin
                  QBi=wordx;
               end
         end
      else
         begin
            if (xflag)
               begin
                  QBi=wordx;
               end
            else
               begin
                  QBi=DBi;
               end
         end
   end
   endtask

   task read_violA;
   begin
      if (valid_address(AAi))
         begin
            QAi=LAST_MEMA;
         end
      else
         begin
            QAi=wordx;
         end
   end
   endtask
   task read_violB;
   begin
      if (valid_address(ABi))
         begin
            QBi=LAST_MEMB;
         end
      else
         begin
            QBi=wordx;
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

   task process_violationsA;
   begin
      if ((NOT_CLKA_PER!==LAST_NOT_CLKA_PER) ||
          (NOT_CLKA_MINH!==LAST_NOT_CLKA_MINH) ||
          (NOT_CLKA_MINL!==LAST_NOT_CLKA_MINL))
         begin
            if (CENAi !== 1'b1)
               begin
                  x_mem;
                  read_memA(0,1);
               end
         end
      else
         begin
            update_Anotifier_buses;
            x_Ainputs;
            update_Alogic;
            if (NOT_CONTA!==LAST_NOT_CONTA)
               begin
                  contentionA;
               end
            else
               begin
                  mem_cycleA(1);
               end
         end
      update_Alast_notifiers;
   end
   endtask

   task process_violationsB;
   begin
      if ((NOT_CLKB_PER!==LAST_NOT_CLKB_PER) ||
          (NOT_CLKB_MINH!==LAST_NOT_CLKB_MINH) ||
          (NOT_CLKB_MINL!==LAST_NOT_CLKB_MINL))
         begin
            if (CENBi !== 1'b1)
               begin
                  x_mem;
                  read_memB(0,1);
               end
         end
      else
         begin
            update_Bnotifier_buses;
            x_Binputs;
            update_Blogic;
            if (NOT_CONTB!==LAST_NOT_CONTB)
               begin
                  contentionB;
               end
            else
               begin
                  mem_cycleB(1);
               end
         end
      update_Blast_notifiers;
   end
   endtask

   function valid_address;
      input [addr_width-1:0] a;
   begin
      valid_address = (^(a) !== 1'bx);
   end
   endfunction

// -----------------------------------------------------------------------------
   buf (QA[0], _QA[0]);
   buf (QA[1], _QA[1]);
   buf (QA[2], _QA[2]);
   buf (QA[3], _QA[3]);
   buf (QA[4], _QA[4]);
   buf (QA[5], _QA[5]);
   buf (QA[6], _QA[6]);
   buf (QA[7], _QA[7]);
   buf (_DA[0], DA[0]);
   buf (_DA[1], DA[1]);
   buf (_DA[2], DA[2]);
   buf (_DA[3], DA[3]);
   buf (_DA[4], DA[4]);
   buf (_DA[5], DA[5]);
   buf (_DA[6], DA[6]);
   buf (_DA[7], DA[7]);
   buf (_AA[0], AA[0]);
   buf (_AA[1], AA[1]);
   buf (_AA[2], AA[2]);
   buf (_AA[3], AA[3]);
   buf (_AA[4], AA[4]);
   buf (_AA[5], AA[5]);
   buf (_AA[6], AA[6]);
   buf (_CLKA, CLKA);
   buf (_WENA, WENA);
   buf (_CENA, CENA);
   buf (QB[0], _QB[0]);
   buf (QB[1], _QB[1]);
   buf (QB[2], _QB[2]);
   buf (QB[3], _QB[3]);
   buf (QB[4], _QB[4]);
   buf (QB[5], _QB[5]);
   buf (QB[6], _QB[6]);
   buf (QB[7], _QB[7]);
   buf (_DB[0], DB[0]);
   buf (_DB[1], DB[1]);
   buf (_DB[2], DB[2]);
   buf (_DB[3], DB[3]);
   buf (_DB[4], DB[4]);
   buf (_DB[5], DB[5]);
   buf (_DB[6], DB[6]);
   buf (_DB[7], DB[7]);
   buf (_AB[0], AB[0]);
   buf (_AB[1], AB[1]);
   buf (_AB[2], AB[2]);
   buf (_AB[3], AB[3]);
   buf (_AB[4], AB[4]);
   buf (_AB[5], AB[5]);
   buf (_AB[6], AB[6]);
   buf (_CLKB, CLKB);
   buf (_WENB, WENB);
   buf (_CENB, CENB);


   assign _QA = QAi;
   assign re_flagA = !(_CENA);
   assign re_data_flagA = !(_CENA || _WENA);
   assign clk_flagA = (CENAi !== 1'b1);
   assign clkrise_qa    = (CENAi !== 1'b1) && (WENAi !== 1'b0);
   assign wt_clkrise_qa = (CENAi !== 1'b1) && (WENAi !== 1'b1);
   assign _QB = QBi;
   assign re_flagB = !(_CENB);
   assign re_data_flagB = !(_CENB || _WENB);
   assign clk_flagB = (CENBi !== 1'b1);
   assign clkrise_qb    = (CENBi !== 1'b1) && (WENBi !== 1'b0);
   assign wt_clkrise_qb = (CENBi !== 1'b1) && (WENBi !== 1'b1);

   assign contA_flag =
      ((_AA === ABi)||(!valid_address(_AA))||(!valid_address(ABi))) &&
      !((_WENA === 1'b1) && (WENBi === 1'b1)) &&
      (_CENA !== 1'b1) &&
      (CENBi !== 1'b1);

   assign contB_flag =
      ((_AB === AAi)||(!valid_address(_AB))||(!valid_address(AAi))) &&
      !((_WENB === 1'b1) && (WENAi === 1'b1)) &&
      (_CENB !== 1'b1) &&
      (CENAi !== 1'b1);

   assign cont_flag =
      ((_AB === _AA)||(!valid_address(_AA))||(!valid_address(_AB))) &&
      !((_WENB === 1'b1) && (_WENA === 1'b1)) &&
      (_CENB !== 1'b1) &&
      (_CENA !== 1'b1);

   always @(
            NOT_AA0 or
            NOT_AA1 or
            NOT_AA2 or
            NOT_AA3 or
            NOT_AA4 or
            NOT_AA5 or
            NOT_AA6 or
            NOT_DA0 or
            NOT_DA1 or
            NOT_DA2 or
            NOT_DA3 or
            NOT_DA4 or
            NOT_DA5 or
            NOT_DA6 or
            NOT_DA7 or
            NOT_WENA or
            NOT_CENA or
            NOT_CONTA or
            NOT_CLKA_PER or
            NOT_CLKA_MINH or
            NOT_CLKA_MINL
            )
      begin
         process_violationsA;
      end
   always @(
            NOT_AB0 or
            NOT_AB1 or
            NOT_AB2 or
            NOT_AB3 or
            NOT_AB4 or
            NOT_AB5 or
            NOT_AB6 or
            NOT_DB0 or
            NOT_DB1 or
            NOT_DB2 or
            NOT_DB3 or
            NOT_DB4 or
            NOT_DB5 or
            NOT_DB6 or
            NOT_DB7 or
            NOT_WENB or
            NOT_CENB or
            NOT_CONTB or
            NOT_CLKB_PER or
            NOT_CLKB_MINH or
            NOT_CLKB_MINL
            )
      begin
         process_violationsB;
      end


   always @( _CLKA )
      begin
         casez({LAST_CLKA,_CLKA})
           2'b01: begin
              latch_Ainputs;
              update_Alogic;
              mem_cycleA(0);
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
              read_memA(1'b0,1'b1);
           end
         endcase
         LAST_CLKA = _CLKA;
      end
   always @( _CLKB )
      begin
         casez({LAST_CLKB,_CLKB})
           2'b01: begin
              latch_Binputs;
              update_Blogic;
              mem_cycleB(0);
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
              read_memB(1'b0,1'b1);
           end
         endcase
         LAST_CLKB = _CLKB;
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
      $setuphold(posedge CLKA, posedge CENA, tsc,thc, NOT_CENA);
      $setuphold(posedge CLKA, negedge CENA, tsc,thc, NOT_CENA);
      $setuphold(posedge CLKA &&& re_flagA, posedge WENA, tsw,thw, NOT_WENA);
      $setuphold(posedge CLKA &&& re_flagA, negedge WENA, tsw,thw, NOT_WENA);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[0], tsa,tha, NOT_AA0);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[0], tsa,tha, NOT_AA0);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[1], tsa,tha, NOT_AA1);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[1], tsa,tha, NOT_AA1);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[2], tsa,tha, NOT_AA2);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[2], tsa,tha, NOT_AA2);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[3], tsa,tha, NOT_AA3);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[3], tsa,tha, NOT_AA3);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[4], tsa,tha, NOT_AA4);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[4], tsa,tha, NOT_AA4);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[5], tsa,tha, NOT_AA5);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[5], tsa,tha, NOT_AA5);
      $setuphold(posedge CLKA &&& re_flagA, posedge AA[6], tsa,tha, NOT_AA6);
      $setuphold(posedge CLKA &&& re_flagA, negedge AA[6], tsa,tha, NOT_AA6);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[0], tsd,thd, NOT_DA0);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[0], tsd,thd, NOT_DA0);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[1], tsd,thd, NOT_DA1);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[1], tsd,thd, NOT_DA1);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[2], tsd,thd, NOT_DA2);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[2], tsd,thd, NOT_DA2);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[3], tsd,thd, NOT_DA3);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[3], tsd,thd, NOT_DA3);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[4], tsd,thd, NOT_DA4);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[4], tsd,thd, NOT_DA4);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[5], tsd,thd, NOT_DA5);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[5], tsd,thd, NOT_DA5);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[6], tsd,thd, NOT_DA6);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[6], tsd,thd, NOT_DA6);
      $setuphold(posedge CLKA &&& re_data_flagA, posedge DA[7], tsd,thd, NOT_DA7);
      $setuphold(posedge CLKA &&& re_data_flagA, negedge DA[7], tsd,thd, NOT_DA7);
      $setuphold(posedge CLKB, posedge CENB, tsc,thc, NOT_CENB);
      $setuphold(posedge CLKB, negedge CENB, tsc,thc, NOT_CENB);
      $setuphold(posedge CLKB &&& re_flagB, posedge WENB, tsw,thw, NOT_WENB);
      $setuphold(posedge CLKB &&& re_flagB, negedge WENB, tsw,thw, NOT_WENB);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[0], tsa,tha, NOT_AB0);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[0], tsa,tha, NOT_AB0);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[1], tsa,tha, NOT_AB1);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[1], tsa,tha, NOT_AB1);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[2], tsa,tha, NOT_AB2);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[2], tsa,tha, NOT_AB2);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[3], tsa,tha, NOT_AB3);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[3], tsa,tha, NOT_AB3);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[4], tsa,tha, NOT_AB4);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[4], tsa,tha, NOT_AB4);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[5], tsa,tha, NOT_AB5);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[5], tsa,tha, NOT_AB5);
      $setuphold(posedge CLKB &&& re_flagB, posedge AB[6], tsa,tha, NOT_AB6);
      $setuphold(posedge CLKB &&& re_flagB, negedge AB[6], tsa,tha, NOT_AB6);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[0], tsd,thd, NOT_DB0);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[0], tsd,thd, NOT_DB0);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[1], tsd,thd, NOT_DB1);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[1], tsd,thd, NOT_DB1);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[2], tsd,thd, NOT_DB2);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[2], tsd,thd, NOT_DB2);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[3], tsd,thd, NOT_DB3);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[3], tsd,thd, NOT_DB3);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[4], tsd,thd, NOT_DB4);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[4], tsd,thd, NOT_DB4);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[5], tsd,thd, NOT_DB5);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[5], tsd,thd, NOT_DB5);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[6], tsd,thd, NOT_DB6);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[6], tsd,thd, NOT_DB6);
      $setuphold(posedge CLKB &&& re_data_flagB, posedge DB[7], tsd,thd, NOT_DB7);
      $setuphold(posedge CLKB &&& re_data_flagB, negedge DB[7], tsd,thd, NOT_DB7);
      // $setup(posedge CLKA, posedge CLKB &&& contB_flag, tc2c, NOT_CONTB);
      // $setup(posedge CLKB, posedge CLKA &&& contA_flag, tc2c, NOT_CONTA);
      // $hold (posedge CLKA, posedge CLKB &&& cont_flag,  tccs, NOT_CONTB);

//      $hold (posedge CLKB, posedge CLKA &&& cont_flag,  tccs, NOT_CONTA);

//      $hold (posedge CLKA, posedge CLKB &&& contB_flag, tc2c, NOT_CONTB);
//      $hold (posedge CLKB, posedge CLKA &&& contA_flag, tc2c, NOT_CONTA);

//      $setuphold(posedge CLKA, posedge CLKB, tc2c, NOT_CONTB,,contB_flag);
//      $setuphold(posedge CLKB, posedge CLKA, tc2c, NOT_CONTA,,contA_flag);

      $period(posedge CLKA &&& clk_flagA, tcp,    NOT_CLKA_PER);
      $period(negedge CLKA &&& clk_flagA, tcp,    NOT_CLKA_PER);
      $width (posedge CLKA &&& clk_flagA, tch, 0, NOT_CLKA_MINH);
      $width (negedge CLKA &&& clk_flagA, tcl, 0, NOT_CLKA_MINL);
      $period(posedge CLKB &&& clk_flagB, tcp,    NOT_CLKB_PER);
      $period(negedge CLKB &&& clk_flagB, tcp,    NOT_CLKB_PER);
      $width (posedge CLKB &&& clk_flagB, tch, 0, NOT_CLKB_MINH);
      $width (negedge CLKB &&& clk_flagB, tcl, 0, NOT_CLKB_MINL);

      if(clkrise_qa) (posedge CLKA=>(QA[0]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[1]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[2]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[3]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[4]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[5]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[6]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qa) (posedge CLKA=>(QA[7]: CLKA)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[0]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[1]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[2]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[3]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[4]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[5]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[6]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);
      if(clkrise_qb) (posedge CLKB=>(QB[7]: CLKB)) = (tcqv, tcqv, tcqx, tcqv, tcqx, tcqv);

      if(wt_clkrise_qa) (posedge CLKA=>(QA[0]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[1]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[2]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[3]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[4]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[5]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[6]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qa) (posedge CLKA=>(QA[7]: CLKA))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[0]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[1]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[2]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[3]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[4]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[5]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[6]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
      if(wt_clkrise_qb) (posedge CLKB=>(QB[7]: CLKB))=(twtv, twtv, twtx, twtv, twtx, twtv);
   endspecify
// -----------------------------------------------------------------------------

endmodule
`endcelldefine
