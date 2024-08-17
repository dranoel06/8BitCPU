module cpu(input clk, output  output_register;);

localparam STATE_FETCH = 0;
localparam STATE_MEM = 1;
localparam STATE_DECODE = 2;
localparam STATE_EXECUTE = 3;
localparam STATE_WRITE_BACK = 4;
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

reg state[4:0];
always @(posedge clk) begin
    if (state == 10) begin
        state <= 0;
    else 
        state <= state + 1;
    end
end



// Bus
wire[7:0] bus;
assign bus = 
    pc_out ? pc :
    ram_out ? ram :
    ir_out ? ir :
    a_out ? a :
    b_out ? b :
    alu_out ? alu :
    8'h00;

// Programm Counter
always @(posedge clk) begin
    if (pc_add) begin
        pc <= pc + 1;
    end

end

// Memory Adress Register
reg[7:0]
always @(posedge clk) begin
    if (mar_in) begin
        mar <= bus;      
    end
    
end

//RAM
reg[7:0] ram[16];
always @(posedge clk) begin
    if (ram_in) begin
        ram[mar] <= bus;
    end
end

//Instruction Register
reg[7:0] ir;
always @(posedge clk) begin
    if (ir_in) begin
        ir <= bus;
    end
end

// ...... WEITERE KOMPONENTEN

//Control Unit
always @(posedge clk) begin
    if (state == STATE_FETCH) begin
        pc_out <= 1;
        mar_in <= 1;
    end
    if (state == ) begin
        
    end
end


endmodule