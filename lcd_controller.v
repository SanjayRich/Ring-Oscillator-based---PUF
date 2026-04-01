module lcd_controller (
    input        clk,
    input        rst,
    input        auth_ok,
    input        auth_fail,
    input        puf_disable,
    output reg   LCD_EN,
    output reg   LCD_RS,
    output reg   LCD_RW,
    output reg [7:0] LCD_DATA
);
    parameter DELAY = 2500000;

    reg [24:0] delay_cnt;
    reg [4:0]  state;
    reg [4:0]  char_idx;
    reg [1:0]  line_sel;

    reg [7:0] L1 [0:15];
    reg [7:0] L2 [0:15];

    localparam S_INIT1=0,S_INIT2=1,S_INIT3=2,
               S_CLEAR=3,S_LINE1=4,S_WRITE1=5,
               S_LINE2=6,S_WRITE2=7,S_DONE=8;

    initial begin
        // will be overwritten by always block
    end

    task load_auth;
        begin
            L1[0]="*";L1[1]="*";L1[2]=" ";L1[3]="A";L1[4]="U";
            L1[5]="T";L1[6]="H";L1[7]="E";L1[8]="N";L1[9]="T";
            L1[10]="I";L1[11]="C";L1[12]="A";L1[13]="T";L1[14]="E";L1[15]="D";
            L2[0]=" ";L2[1]=" ";L2[2]="F";L2[3]="P";L2[4]="G";
            L2[5]="A";L2[6]=" ";L2[7]="1";L2[8]=" ";L2[9]=" ";
            L2[10]="O";L2[11]="K";L2[12]=" ";L2[13]=" ";L2[14]=" ";L2[15]=" ";
        end
    endtask

    task load_fail;
        begin
            L1[0]="!";L1[1]="!";L1[2]=" ";L1[3]="A";L1[4]="U";
            L1[5]="T";L1[6]="H";L1[7]=" ";L1[8]="F";L1[9]="A";
            L1[10]="I";L1[11]="L";L1[12]="E";L1[13]="D";L1[14]="!";L1[15]=" ";
            L2[0]=" ";L2[1]="W";L2[2]="R";L2[3]="O";L2[4]="N";
            L2[5]="G";L2[6]=" ";L2[7]="F";L2[8]="P";L2[9]="G";
            L2[10]="A";L2[11]=" ";L2[12]="C";L2[13]="H";L2[14]="I";L2[15]="P";
        end
    endtask

    task load_disable;
        begin
            L1[0]=" ";L1[1]="P";L1[2]="U";L1[3]="F";L1[4]=" ";
            L1[5]="D";L1[6]="I";L1[7]="S";L1[8]="A";L1[9]="B";
            L1[10]="L";L1[11]="E";L1[12]="D";L1[13]=" ";L1[14]=" ";L1[15]=" ";
            L2[0]="W";L2[1]="E";L2[2]="L";L2[3]="C";L2[4]="O";
            L2[5]="M";L2[6]="E";L2[7]=":";L2[8]=" ";L2[9]="F";
            L2[10]="P";L2[11]="G";L2[12]="A";L2[13]="-";L2[14]="2";L2[15]=" ";
        end
    endtask

    task load_init;
        begin
            L1[0]=" ";L1[1]=" ";L1[2]="P";L1[3]="U";L1[4]="F";
            L1[5]=" ";L1[6]="S";L1[7]="E";L1[8]="C";L1[9]="U";
            L1[10]="R";L1[11]="I";L1[12]="T";L1[13]="Y";L1[14]=" ";L1[15]=" ";
            L2[0]=" ";L2[1]="G";L2[2]="E";L2[3]="N";L2[4]="E";
            L2[5]="R";L2[6]="A";L2[7]="T";L2[8]="I";L2[9]="N";
            L2[10]="G";L2[11]=" ";L2[12]="K";L2[13]="E";L2[14]="Y";L2[15]=" ";
        end
    endtask

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= S_INIT1; delay_cnt <= 0;
            char_idx <= 0; LCD_EN <= 0;
            LCD_RS <= 0; LCD_RW <= 0;
            LCD_DATA <= 8'h00; line_sel <= 0;
        end else begin
            case (state)
                S_INIT1: begin
                    if (delay_cnt < DELAY) delay_cnt <= delay_cnt+1;
                    else begin
                        delay_cnt<=0; LCD_RS<=0; LCD_RW<=0;
                        LCD_DATA<=8'h38; LCD_EN<=1; state<=S_INIT2;
                    end
                end
                S_INIT2: begin
                    LCD_EN<=0;
                    if (delay_cnt<10) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0; LCD_DATA<=8'h0C;
                        LCD_EN<=1; state<=S_INIT3;
                    end
                end
                S_INIT3: begin
                    LCD_EN<=0;
                    if (delay_cnt<10) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0; LCD_DATA<=8'h06;
                        LCD_EN<=1; state<=S_CLEAR;
                    end
                end
                S_CLEAR: begin
                    LCD_EN<=0;
                    if (delay_cnt < DELAY/5) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0; char_idx<=0;
                        if      (puf_disable) begin load_disable; line_sel<=2; end
                        else if (auth_ok)     begin load_auth;    line_sel<=1; end
                        else if (auth_fail)   begin load_fail;    line_sel<=2; end
                        else                  begin load_init;    line_sel<=0; end
                        LCD_DATA<=8'h01; LCD_RS<=0;
                        LCD_EN<=1; state<=S_LINE1;
                    end
                end
                S_LINE1: begin
                    LCD_EN<=0;
                    if (delay_cnt<10) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0; LCD_RS<=0;
                        LCD_DATA<=8'h80; LCD_EN<=1;
                        char_idx<=0; state<=S_WRITE1;
                    end
                end
                S_WRITE1: begin
                    LCD_EN<=0;
                    if (delay_cnt<5) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0;
                        if (char_idx<16) begin
                            LCD_RS<=1; LCD_DATA<=L1[char_idx];
                            LCD_EN<=1; char_idx<=char_idx+1;
                        end else begin
                            char_idx<=0; state<=S_LINE2;
                        end
                    end
                end
                S_LINE2: begin
                    LCD_EN<=0; LCD_RS<=0;
                    LCD_DATA<=8'hC0; LCD_EN<=1;
                    state<=S_WRITE2;
                end
                S_WRITE2: begin
                    LCD_EN<=0;
                    if (delay_cnt<5) delay_cnt<=delay_cnt+1;
                    else begin
                        delay_cnt<=0;
                        if (char_idx<16) begin
                            LCD_RS<=1; LCD_DATA<=L2[char_idx];
                            LCD_EN<=1; char_idx<=char_idx+1;
                        end else begin
                            state<=S_DONE;
                        end
                    end
                end
                S_DONE: begin
                    LCD_EN<=0;
                    if (delay_cnt<DELAY) delay_cnt<=delay_cnt+1;
                    else begin delay_cnt<=0; state<=S_CLEAR; end
                end
            endcase
        end
    end
endmodule