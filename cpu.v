module cpu(input clk, output reg[7:0] output_register);

parameter LDA = 4'b0001;
parameter ADD = 4'b0010;
parameter OUT = 4'b0011;

reg pc_in;
reg pc_out;
reg pc_add;
reg mar_in;
reg ram_in;
reg ram_out;
reg ir_in;
reg ir_out;
reg a_in;
reg a_out;
reg b_in;
reg b_out;
reg alu_out;
reg output_in;

//Clock
reg[31:0] clk_counter;
always @(posedge clk) begin

    clk_counter <= clk_counter + 1;

    if (clk_counter > 13500000)  begin
        
        clk_counter <= 0;
    end


    if (clk_counter < 7000000) begin
        cpu_clk <= 1;
    end
    else begin
        cpu_clk <= 0;
    end

    
end


// Instruction Step Counter
reg[5:0] step;
always @(posedge cpu_clk) begin
        step <= step + 1;

    if (step == 8) begin
        step <= 0;   
    end


end



// Bus
wire[7:0] bus;
assign bus = 
    pc_out ? pc :
    ram_out ? ram[mar] :
    ir_out ? ir[3:0] : //// ?
    a_out ? a :
    b_out ? b :
    alu_out ? alu :
    8'h00;

// Programm Counter
reg[7:0] pc =0;
always @(posedge cpu_clk) begin
    if (pc_add) begin
        pc <= pc + 1;
    end

end

// Memory Adress Register
reg[7:0] mar;
always @(posedge cpu_clk) begin
    if (mar_in) begin
        mar <= bus[3:0];      
    end
    
end

//RAM
reg[7:0] ram[16];
always @(posedge cpu_clk) begin
    if (ram_in) begin
        ram[mar] <= bus;
    end
end

//Instruction Register
reg[7:0] ir;
always @(posedge cpu_clk) begin
    if (ir_in) begin
        ir <= bus;
    end
end


//Output Register
always @(posedge cpu_clk) begin
    if (output_in) begin
        output_register <= bus;
    end
    
end

//A Register
reg[7:0] a_reg;
always @(posedge cpu_clk) begin
    if (a_in) begin
        a_reg <= bus;
    end
    
end
//B Register
reg[7:0] b_reg;
always @(posedge cpu_clk) begin
    if (b_in) begin
        b_reg <= bus;
    end
    
end

//ALU
reg[7:0] alu;
always @(posedge cpu_clk) begin
    if (alu_out) begin
        alu <= a_reg + b_reg;
    end
    
end

// ...... WEITERE KOMPONENTEN

//FETCH STAGE
always @(negedge cpu_clk) begin
    case (step)
        1: begin
          pc_out <= 1;
          mar_in <= 1;
          ram_in <= 1;
        end
        2: begin
          ram_out <= 1;
          ir_in <= 1;
          pc_add <= 1;
        end
        //default: 
    endcase
end

//Control Unit
always @(negedge cpu_clk) begin
    if (ir[7:4] == ADD) begin
        case (step)
            3: begin
              ir_out <= 1;
              mar_in <= 1;
              ram_in <= 1;
            end
            4: begin
              ram_out <= 1;
              b_in <= 1;
            end
            5: begin
              alu_out <= 1;
              a_in <= 1;
            end
            //default: 
        endcase
        
    end
    if (it[7:4] == LDA) begin
        case (step)
            3: begin
              ir_out <= 1;
              mar_in <= 1;
              ram_in <= 1;
            end
            4: begin
              ram_out <= 1;
              a_in <= 1;
            end 
            //default: 
        endcase
        
    end
    if (ir[7:4] == OUT) begin
        case (step)
            3: begin
                a_out <= 1;
                output_in <= 1;
            end 
            //default: 
        endcase
        
    end
    
    
end
initial begin
    

mem[0] = {LDA, 4'hF};
mem[1] = {OUT, 4'h0}; 
mem[2] = {ADD, 4'hF}; 
mem[3] = {OUT, 4'h0}; 
mem[4] = {ADD, 4'hF}; 
mem[5] = {OUT, 4'h0}; 
mem[6] = {ADD, 4'hF}; 
mem[7] = {OUT, 4'h0}; 
mem[8] = {ADD, 4'hF}; 
mem[9] = {OUT, 4'h0}; 
mem[10] = {ADD, 4'hF}; 
mem[11] = {OUT, 4'h0};
mem[12] = {ADD, 4'hF};
mem[13] = {OUT, 4'h0};
mem[14] = {ADD, 4'hF};
mem[15] = 8'b00000001;

end

endmodule

module top(input clk, output reg [7:0] output_register);

    cpu test(clk, output_register);

endmodule