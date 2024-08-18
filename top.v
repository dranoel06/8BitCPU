module top(input clk, button_in, output [6:0] display, output [3:0] digit_select, output [7:0]  bus_viewer_out);
    wire [7:0] signal;
    wire [7:0] bus_viewer;
    wire button_wire;

    PushButton_Debouncer btn(
        .clk(clk),
        .PB(button_in),
        .PB_state(button_wire)

     );

    // Instanzierung von cpu
    cpu cpu0(
        .clk(clk),
        .button(button_wire),
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