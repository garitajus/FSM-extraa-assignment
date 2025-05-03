module cerrojo_fsm (
    input logic clk, rst,
    input logic PUSHED, LOCKED, ECNT3, WAITDONE,
    input logic [3:0] NUM,
    output logic UNLOCK, CLRCNTR, CLRTIMER, INC
);

    typedef enum logic [5:0] {
        A = 6'b000001,
        B = 6'b000010,
        C = 6'b000100,
        D = 6'b001000,
        E = 6'b010000,
        F = 6'b100000
    } state_t;

    state_t state, next;

    // Lógica de transición de estados
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= A;
        else
            state <= next;
    end

    // Lógica combinacional de siguiente estado y salidas
    always_comb begin
        // Valores por defecto
        next = state;
        UNLOCK = 0;
        CLRCNTR = 0;
        CLRTIMER = 0;
        INC = 0;

        case (state)
            A: begin
                if (ECNT3) next = F;
                else if (LOCKED) begin
                    next = A;
                    CLRCNTR = 1;
                end
                else if (PUSHED) begin
                    if (NUM == 4'd7) next = B;
                    else begin
                        next = E;
                        INC = 1;
                    end
                end
            end

            B: begin
                if (PUSHED) begin
                    if (NUM == 4'd8) next = C;
                    else begin
                        next = E;
                        INC = 1;
                    end
                end
            end

            C: begin
                if (PUSHED) begin
                    if (NUM == 4'd9) begin
                        next = D;
                        UNLOCK = 1;
                    end
                    else begin
                        next = E;
                        INC = 1;
                    end
                end
            end

            D: begin
                if (LOCKED) begin
                    next = A;
                    CLRCNTR = 1;
                end
            end

            E: begin
                if (ECNT3) begin
                    next = F;
                    CLRTIMER = 1;
                end else begin
                    next = A;
                end
            end

            F: begin
                if (WAITDONE) begin
                    next = A;
                    CLRCNTR = 1;
                end
            end
        endcase
    end

endmodule
