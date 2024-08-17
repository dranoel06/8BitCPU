module top(input clk, output [6:0] display, output [3:0] digit_select, output [7:0]  bus_viewer_out);
    wire [7:0] signal;
    wire [7:0] bus_viewer;


    // Instanzierung von cpu
    cpu cpu0(
        .clk(clk),
        .output_register(signal),
        .bus_viewer(bus_viewer)

    );

    // Instanzierung von sevenseg
    sevenseg disp(
        .clk(clk),
        .number(signal),
        .display(display),
        .digit_select(digit_select)
    );

    assign bus_viewer_out = bus_viewer;

endmodule