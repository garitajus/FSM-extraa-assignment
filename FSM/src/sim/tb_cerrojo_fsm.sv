`timescale 1ns/1ps

module tb_cerrojo_fsm;

  logic clk, rst;
  logic [3:0] NUM;
  logic PUSHED;
  logic UNLOCK, LOCKED, INC, CLRCNTR, CLRTIMER;
  logic ECNT3, WAITDONE;

  // Instancia del DUT
  cerrojo_fsm dut (
    .clk(clk),
    .rst(rst),
    .NUM(NUM),
    .PUSHED(PUSHED),
    .UNLOCK(UNLOCK),
    .LOCKED(LOCKED),
    .INC(INC),
    .CLRCNTR(CLRCNTR),
    .CLRTIMER(CLRTIMER),
    .ECNT3(ECNT3),
    .WAITDONE(WAITDONE)
  );

  // Generador de reloj
  always #5 clk = ~clk;

  initial begin
    $display("Inicio de simulación");
        $dumpfile("tb_cerrojo_fsm.vcd");
        $dumpvars(0, tb_cerrojo_fsm);

    // Inicialización
    clk = 0;
    rst = 1;
    NUM = 0;
    PUSHED = 0;
    ECNT3 = 0;
    WAITDONE = 0;
    LOCKED = 0;
    #20;
    
    rst = 0;
    #20;

    // === Primer intento incorrecto ===
    ingresar_codigo(4'd1);  // incorrecto
    #20;

    // === Segundo intento incorrecto ===
    ingresar_codigo(4'd2);
    #20;

    // === Tercer intento incorrecto ===
    ingresar_codigo(4'd3);
    #20;

    // Simular que contador de errores llegó a 3
    ECNT3 = 1;
    #10;
    ECNT3 = 0;

    // Tiempo de castigo simulado
    WAITDONE = 0;  // aún castigado
    ingresar_codigo(4'd7);  // correcto pero no debe funcionar
    #20;

    // Ahora termina el castigo
    WAITDONE = 1;
    #10;
    WAITDONE = 0;

    // Ahora debería poder ingresar clave correcta
    ingresar_codigo(4'd7);
    ingresar_codigo(4'd8);
    ingresar_codigo(4'd9);
    #20;

    $finish;
  end

  // Task para simular ingreso de número
  task ingresar_codigo(input [3:0] valor);
    begin
      NUM = valor;
      PUSHED = 1;
      #10;
      PUSHED = 0;
      #10;
    end
  endtask

endmodule
