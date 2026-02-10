module cpu(input clk, button, output reg[7:0] output_register, output reg[7:0] bus_viewer);

parameter CLOCK_SPEED = 300000; // 480000 for 1 sec

parameter LDA = 3'b001;
parameter ADD = 3'b010;
parameter OUT = 3'b011;
parameter JMP = 3'b100;
parameter STA = 3'b101;
parameter LDI = 3'b110;
parameter SUB = 3'b111;
parameter BEQ = 3'b000;


reg pc_in;
reg pc_out;
reg pc_add;
reg mar_in;
reg ram_in;
reg ram_out;
reg ir_in;
reg ir_out; 
reg a_in;
reg a_imm_in;
reg a_out;
reg b_in;
reg b_out;
reg output_in;
reg alu_op;

reg[3:0] step_limit;


always @(posedge clk) begin
    bus_viewer <= bus;

end


/*
// Button
assign cpu_clk = button;
assign bus_viewer = step;
assign output_register = alu;
*/


//Clock
reg[31:0] clk_counter;
reg cpu_clk;

always @(posedge clk) begin
    clk_counter <= clk_counter + 1;

    if (clk_counter > CLOCK_SPEED)  begin       
        clk_counter <= 1'b0;
    end

    cpu_clk <= (clk_counter < CLOCK_SPEED/2) ? 1'b1 : 1'b0;
end


// Instruction Step Counter
reg[5:0] step;
always @(posedge cpu_clk) begin // negedge ????? 
    step <= step + 5'd1;

    if (step > step_limit) begin
        step <= 5'd1;   
    end
    else if (step > 7) begin
        step <= 5'd1;
    end
end



// Bus
wire[7:0] bus;
assign bus = 
    pc_out ? pc :
    ram_out ? ram[mar] :
    ir_out ? ir[4:0] : 
    a_out ? a_reg :
    b_out ? b_reg :
    alu_out ? alu :
    8'b0;

// Programm Counter
reg[7:0] pc;
always @(posedge cpu_clk) begin
    if (pc_add) begin
        pc <= pc + 1'b1;
    end
    if (pc_in) begin 
        pc <= {3'b0, bus[4:0]};
    end
    
end


// Memory Adress Register
reg[4:0] mar;
always @(posedge cpu_clk) begin
    if (mar_in) begin
        mar <= bus[4:0];      
    end 
end


//RAM
reg[7:0] ram[32];
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
    else if (a_imm_in) begin
        a_reg <= {3'b0, bus[4:0]};
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
wire [7:0] alu;
assign alu = (alu_op == 1'b0) ? (a_reg + b_reg) :
                    (alu_op == 1'b1) ? (a_reg - b_reg) :
                    a_reg; 

wire zero_flag;
assign zero_flag = (a_reg == 8'b00000000) ? 1'b1 : 1'b0;



//Control Unit
always @(negedge cpu_clk) begin

    pc_in <= 1'b0;
    pc_out <= 1'b0; 
    pc_add <= 1'b0;
    mar_in <= 1'b0;
    ram_in <= 1'b0;
    ram_out <= 1'b0;
    ir_in <= 1'b0;
    ir_out <= 1'b0;
    a_in <= 1'b0;
    a_imm_in <= 1'b0;
    a_out <= 1'b0;
    b_in <= 1'b0;
    b_out <= 1'b0;
    alu_out <= 1'b0;
    alu_op <= 1'b0;
    output_in <= 1'b0;

    if (step == 5'd1) begin
        pc_out <= 1'b1;
        mar_in <= 1'b1;
    end
    else if (step == 5'd2) begin
        ram_out <= 1'b1;
        ir_in <= 1'b1;
        pc_add <= 1'b1;
    end  
    
    else if (ir[7:5] == ADD) begin // ADD
    step_limit <= 3'd6;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            mar_in <= 1'b1;
        end
        else if (step == 5'd4) begin
            ram_out <= 1'b1;
            b_in <= 1'b1;
        end
        else if (step == 5'd6) begin
            alu_out <= 1'b1;
            alu_op <= 1'b0;
            a_in <= 1'b1;
        end       
    end
    
    else if (ir[7:5] == SUB) begin // SUB
    step_limit <= 3'd6;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            mar_in <= 1'b1;
        end
        else if (step == 5'd4) begin
            ram_out <= 1'b1;
            b_in <= 1'b1;
        end
        else if (step == 5'd6) begin
            alu_op <= 1'b1;
            alu_out <= 1'b1;
            a_in <= 1'b1;
        end       
    end

    else if (ir[7:5] == LDA) begin // LDA
    step_limit <= 3'd4;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            mar_in <= 1'b1;
        end
        else if (step == 5'd4) begin
            ram_out <= 1'b1;
            a_in <= 1'b1;
        end
    end

    else if (ir[7:5] == LDI) begin // LDI
        step_limit <= 3'd3;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            a_imm_in <= 1'b1;
        end
    end

    else if (ir[7:5] == STA) begin // STA
    step_limit <= 3'd4;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            mar_in <= 1'b1;
        end
        else if (step == 5'd4) begin
            a_out <= 1'b1;
            ram_in <= 1'b1;
        end
    end

    else if (ir[7:5] == OUT) begin // OUT
    step_limit <= 3'd3;
        if (step == 5'd3) begin
            a_out <= 1'b1;
            output_in <= 1'b1;
        end
    end

    else if (ir[7:5] == JMP) begin // JMP
    step_limit <= 3'd3;
        if (step == 5'd3) begin
            ir_out <= 1'b1;
            pc_in <= 1'b1;
        end
    end

    else if (ir[7:5] == BEQ) begin // BEQ
    step_limit <= 3'd3;
        if (step == 5'd3) begin
            if (zero_flag == 1'b1) begin
                ir_out <= 1'b1;
                pc_in <= 1'b1;
            end        
        end
    end
       
end

// Programm
initial begin

ram[0] = {LDI, 5'h1}; // Fibonacci
ram[1] = {STA, 5'hD}; 
ram[2] = {LDI, 5'h0}; 
ram[3] = {STA, 5'hE};
ram[4] = {LDA, 5'hD}; 
ram[5] = {ADD, 5'hE};  
ram[6] = {OUT, 5'h0}; 
ram[7] = {STA, 5'hF}; 
ram[8] = {LDA, 5'hD};
ram[9] = {STA, 5'hE}; 
ram[10] = {LDA, 5'hF};  
ram[11] = {STA, 5'hD}; 
ram[12] = {JMP, 5'h4}; 
ram[13] = {8'h01};      
ram[14] = {8'h00};      


/*
ram[0] = {LDA, 4'h7}; // 2^x
ram[1] = {STA, 4'h8}; 
ram[2] = {LDA, 4'h8}; 
ram[3] = {OUT, 4'h0};
ram[4] = {ADD, 4'h8};
ram[5] = {STA, 4'h8};
ram[6] = {JMP, 4'h2};
ram[7] = {8'h01}; 
*/

/*
ram[0] = {LDI, 5'd11};
ram[1] = {STA, 5'h10};
ram[2] = {LDA, 5'hD};  
ram[3] = {OUT, 5'h0}; 
ram[4] = {ADD, 5'hD}; 
ram[5] = {STA, 5'hF};
ram[6] = {SUB, 5'h10};
ram[7] = {BEQ, 5'hA};
ram[8] = {LDA, 5'hF};
ram[9] = {JMP, 5'h3};
ram[10] = {LDA, 5'hF};
ram[11] = {OUT, 5'h0};
ram[12] = {JMP, 5'hC};
ram[13] = {8'h01}; 


/*
ram[0] = {LDA, 4'h5};  // Count Down
ram[1] = {OUT, 4'h0}; 
ram[2] = {SUB, 4'h4}; 
ram[3] = {JMP, 4'h1};
ram[4] = {8'h01}; 
ram[5] = {8'hFF};
*/



end


endmodule