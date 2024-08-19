module cpu(input clk, button, output reg[7:0] output_register, output reg[7:0] bus_viewer);

parameter CLOCK_SPEED = 800000; // 480000 for 1 sec

parameter LDA = 4'b0001;
parameter ADD = 4'b0010;
parameter OUT = 4'b0011;
parameter JMP = 4'b0100;
parameter STA = 4'b0101;
parameter LDI = 4'b0110;

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
reg alu_out;
reg output_in;

reg[3:0] step_limit;


always @(posedge clk) begin
    bus_viewer <= bus;
end

//Bad Reset Button
reg reset;
reg button_counter;
always @(posedge button) begin
    button_counter <= button_counter + 1;
    reset <= (button_counter < 1) ? 0 : 1;
end


/*
// Button
assign cpu_clk = button;
assign bus_viewer = step;
*/



//Clock
reg[31:0] clk_counter;
reg cpu_clk;
always @(posedge clk) begin
    clk_counter <= clk_counter + 1;

    if (clk_counter > CLOCK_SPEED)  begin       
        clk_counter <= 0;
    end

    cpu_clk <= (clk_counter < CLOCK_SPEED/2) ? 1 : 0;
end


// Instruction Step Counter
reg[5:0] step;
always @(posedge cpu_clk) begin // negedge ?????
    step <= step + 1;

    if (step > step_limit) begin
        step <= 1;   
    end
    else if (step > 7) begin
        step <= 1;
    end
end



// Bus
wire[7:0] bus;
assign bus = 
    pc_out ? pc :
    ram_out ? ram[mar] :
    ir_out ? ir[3:0] : 
    a_out ? a_reg :
    b_out ? b_reg :
    alu_out ? alu :
    8'b0;

// Programm Counter
reg[7:0] pc;
always @(posedge cpu_clk) begin
    if (pc_add) begin
        pc <= pc + 1;
    end
    if (pc_in) begin 
        pc <= {4'b0, bus[3:0]};
    end
    if (reset) begin
        pc <= 0;
    end

    
end


// Memory Adress Register
reg[3:0] mar;
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
    else if (a_imm_in) begin
        a_reg <= {4'b0, bus[3:0]};
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
    alu <= a_reg + b_reg;  
end


//Control Unit
always @(negedge cpu_clk) begin

    pc_in <= 0;
    pc_out <= 0; 
    pc_add <= 0;
    mar_in <= 0;
    ram_in <= 0;
    ram_out <= 0;
    ir_in <= 0;
    ir_out <= 0;
    a_in <= 0;
    a_imm_in <= 0;
    a_out <= 0;
    b_in <= 0;
    b_out <= 0;
    alu_out <= 0;
    output_in <= 0;

    if (step == 1) begin
        pc_out <= 1;
        mar_in <= 1;
    end
    else if (step == 2) begin
        ram_out <= 1;
        ir_in <= 1;
        pc_add <= 1;
    end  
    
    else if (ir[7:4] == ADD) begin // ADD
    step_limit <= 6;
        if (step == 3) begin
            ir_out <= 1;
            mar_in <= 1;
        end
        else if (step == 4) begin
            ram_out <= 1;
            b_in <= 1;
        end
        else if (step == 6) begin
            alu_out <= 1;
            a_in <= 1;
        end       
    end

    else if (ir[7:4] == LDA) begin // LDA
    step_limit <= 4;
        if (step == 3) begin
            ir_out <= 1;
            mar_in <= 1;
        end
        else if (step == 4) begin
            ram_out <= 1;
            a_in <= 1;
        end
    end

    else if (ir[7:4] == LDI) begin // LDI
        step_limit <= 3;
        if (step == 3) begin
            ir_out <= 1;
            a_imm_in <= 1;
        end
    end

    else if (ir[7:4] == STA) begin // STA
    step_limit <= 4;
        if (step == 3) begin
            ir_out <= 1;
            mar_in <= 1;
        end
        else if (step == 4) begin
            a_out <= 1;
            ram_in <= 1;
        end
    end

    else if (ir[7:4] == OUT) begin // OUT
    step_limit <= 3;
        if (step == 3) begin
            a_out <= 1;
            output_in <= 1;
        end
    end

    else if (ir[7:4] == JMP) begin // JMP
    step_limit <= 3;
        if (step == 3) begin
            ir_out <= 1;
            pc_in <= 1;
        end
    end

       
end

// Programm
initial begin

ram[0] = {LDI, 4'h1}; // Fibonacci
ram[1] = {STA, 4'hD}; 
ram[2] = {LDI, 4'h0}; 
ram[3] = {STA, 4'hE};
ram[4] = {LDA, 4'hD}; 
ram[5] = {ADD, 4'hE};  
ram[6] = {OUT, 4'h0}; 
ram[7] = {STA, 4'hF}; 
ram[8] = {LDA, 4'hD};
ram[9] = {STA, 4'hE}; 
ram[10] = {LDA, 4'hF};  
ram[11] = {STA, 4'hD}; 
ram[12] = {JMP, 4'h4}; 
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
ram[0] = {LDA, 4'h4};  // Count Up
ram[1] = {OUT, 4'h0}; 
ram[2] = {ADD, 4'h4}; 
ram[3] = {JMP, 4'h1};
ram[4] = {8'h01}; 
*/

end


endmodule