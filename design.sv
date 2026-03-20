module i2c_master #(parameter sys_clk=50000000, i2c_clk=100000)
  (input  clk, rst, rw, start,
   input  [6:0] addr,
   input  [7:0] datain,
   output wire  scl,
   inout  wire  sda,
   output [7:0] dataout);

  reg [7:0] dataout;
  wire sda_in = sda;
  reg  ack_error;

  localparam integer half_period = sys_clk / (i2c_clk * 2); 

  reg scl_drive_low, sda_drive_low;

  pullup(sda);
  pullup(scl);

  assign sda = sda_drive_low ? 1'b0 : 1'bz;
  assign scl = scl_drive_low ? 1'b0 : 1'bz;

  reg [15:0] count;
  reg        scl_phase;

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      count     <= 0;
      scl_phase <= 0;
    end else begin
      if (count == half_period - 1) begin
        count     <= 0;
        scl_phase <= ~scl_phase;
      end else
        count <= count + 1;
    end
  end

  typedef enum logic [2:0] {IDLE, START, ADDR, ADDR_ACK,
                              DATA, DATA_ACK, STOP} state_t;
  state_t state;

  reg [3:0] bit_count;
  reg [7:0] shift_reg;

  reg start_latch;

  always @(posedge clk or posedge rst)
    begin
    if (rst)
      start_latch <= 0;
    else if (start)
      start_latch <= 1;
    else if (count == half_period - 1 && state == IDLE && start_latch)
      start_latch <= 0;
  end

  always @(posedge clk or posedge rst) 
    begin
    if (rst) 
      begin
      shift_reg     <= 0;
      bit_count     <= 0;
      state         <= IDLE;
      scl_drive_low <= 0;
      sda_drive_low <= 0;
      ack_error     <= 0;
      dataout       <= 0;
    end
      else if (count == half_period - 1) 
        begin
      case (state)

        IDLE: begin
          shift_reg <= 0;
          bit_count <= 0;
          scl_drive_low <= 0;
          sda_drive_low <= 0;
          if (start_latch)
            begin
            state <= START;
            bit_count <= 7;
            shift_reg <= {addr, rw};
            end
        end

        START: begin
          if (scl_phase)
            begin
            scl_drive_low <= 0;
            sda_drive_low <= 1;
            state <= ADDR;
            end
        end

        ADDR: begin
          if (!scl_phase) 
            begin
            scl_drive_low <= 1;
            sda_drive_low <= ~shift_reg[bit_count];
          end 
          else
            begin
            scl_drive_low <= 0;
            if (bit_count == 0)
              state <= ADDR_ACK;
            else
              bit_count <= bit_count - 1;
          end
        end

        ADDR_ACK: begin
          if (!scl_phase)
            begin
            scl_drive_low <= 1;
            sda_drive_low <= 0;
          end 
          else
            begin
            scl_drive_low <= 0;
            if (sda_in)
              begin
              ack_error <= 1;
              state     <= STOP;
            end
              else
                begin
              ack_error <= 0;
              bit_count <= 7;
              shift_reg <= datain;
              state     <= DATA;
            end
          end
        end

        DATA: begin
          if (!rw) 
            begin
            if (!scl_phase) 
              begin
              scl_drive_low <= 1;
              sda_drive_low <= ~shift_reg[bit_count];
            end 
            else
              begin
              scl_drive_low <= 0;
              if (bit_count == 0) state <= DATA_ACK;
              else bit_count <= bit_count - 1;
            end
          end 
          else
            begin
            if (!scl_phase)
              begin
              scl_drive_low <= 1;
              sda_drive_low <= 0;
            end 
            else 
              begin
              scl_drive_low      <= 0;
              dataout[bit_count] <= sda_in;
              if (bit_count == 0)
                state <= DATA_ACK;
              else            
                bit_count <= bit_count - 1;
            end
          end
        end

        DATA_ACK: begin
          if (!scl_phase) 
            begin
            scl_drive_low <= 1;
            sda_drive_low <= 0;
          end 
          else 
            begin
            scl_drive_low <= 0;
            if (rw) 
              begin
              state <= STOP;
            end 
            else
              begin
              if (sda_in) 
                ack_error <= 1;
              else     
                begin
                ack_error <= 0;
                end
              state <= STOP;
            end
          end
        end

        STOP: begin
          if (!scl_phase)
            begin
            scl_drive_low <= 1;
            sda_drive_low <= 0;
          end 
          else
            begin
            scl_drive_low <= 0;
            sda_drive_low <= 0;
            state <= IDLE;
          end
        end
      endcase
    end
  end
endmodule


module i2c_slave  #(parameter SLAVE_ADDR = 7'h32)(input wire scl, inout wire sda);

  reg sda_oe;
  assign sda = sda_oe ? 1'b0 : 1'bz;

  localparam [2:0] IDLE =3'd0,
                   ADDR =3'd1,
                   ADDR_ACK =3'd2,
                   WDATA_PRE =3'd3,  
                   WDATA =3'd4,  
                   WACK =3'd5,  
                   RDATA =3'd6,  
                   RDATA_HOLD =3'd7;  

  reg [2:0] state;
  reg [2:0] bit_count;
  reg [7:0] addr_shift;
  reg [7:0] rx_shift;
  reg started;
  reg [2:0] tx_bit;

  reg [7:0] mem = 8'h00;

  initial begin
    state = IDLE;
    bit_count = 7;
    addr_shift = 0;
    rx_shift = 0;
    sda_oe = 0;
    started = 0;
    tx_bit = 7;
    mem = 8'h00;
  end

  always @(negedge sda) begin
    if (scl == 1'b1)
      begin
      started <= 1;
      state <= ADDR;
      bit_count <= 7;
      addr_shift <= 0;
      rx_shift <= 0;
      sda_oe <= 0;
    end
  end

  always @(posedge sda) 
    begin
    if (scl == 1'b1) 
      begin
      started <= 0;
      state   <= IDLE;
      sda_oe  <= 0;
    end
  end

  
  always @(posedge scl) begin
    if (started) begin
      case (state)

        ADDR: 
          begin
          addr_shift[bit_count] <= sda;
          if (bit_count == 0)
            state <= ADDR_ACK;
          else
            bit_count <= bit_count - 1;
        end

        WDATA_PRE: ;    

        WDATA: begin
          rx_shift[bit_count] <= sda;
          if (bit_count == 0)
            state <= WACK;
          else
            bit_count <= bit_count - 1;
        end

        RDATA_HOLD: ;

        default: ;
      endcase
    end
  end

  
  always @(negedge scl) begin
    if (!started) begin
      sda_oe <= 0;
    end else begin
      case (state)
        
        
        ADDR_ACK: begin
          if (addr_shift[7:1] == SLAVE_ADDR)
            begin
            sda_oe <= 1;           

            if (addr_shift[0] == 1'b0) 
              begin
              state <= WDATA_PRE; 
              $display("[SLAVE] WRITE: address matched");
            end 
              else 
                begin
              tx_bit <= 7;
              state  <= RDATA; 
              $display("[SLAVE] READ: address matched, mem=0x%0h", mem);
            end
          end
          else 
            begin
            sda_oe <= 0;            
            state  <= IDLE;
          end
        end

        WDATA_PRE: begin
          sda_oe    <= 0;
          bit_count <= 7;
          rx_shift  <= 0;
          state     <= WDATA;
        end

        
        WDATA: begin
          sda_oe <= 0;
        end

        WACK: begin
          mem    <= rx_shift;
          sda_oe <= 1;
          $display("[SLAVE] WRITE stored: mem=0x%0h (%0d decimal)", rx_shift, rx_shift);
          state   <= IDLE;
          started <= 0;
        end

        RDATA: begin
          sda_oe <= ~mem[tx_bit];
          $display("[SLAVE] READ bit[%0d]=%0b  mem=0x%0h", tx_bit, mem[tx_bit], mem);
          if (tx_bit == 0) begin
            state <= RDATA_HOLD;
          end else begin
            tx_bit <= tx_bit - 1;
          end
        end

        RDATA_HOLD: begin
          sda_oe  <= 0;
          state   <= IDLE;
          started <= 0;
        end

        default: sda_oe <= 0;

      endcase
    end
  end

endmodule
