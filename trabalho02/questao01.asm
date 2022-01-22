;----------------------------------------------------------------------
; Programa: Operações aritméticas com dois números de 8 bits em complemento a dois
; Descrição: O programa conta com uma rotina para somar ou multiplicar dois números. O resultado é
; armazenado em uma variável de 16 bits. Exibe 1 no visor, se houve overflow, ou 0, caso contrário
; Parâmetros: Endereços dos dois números de 8 bits e endereço da variável de 16 bits são passados
; na pilha. No acumulador a rotina recebe 1, caso a operação seja uma multiplicação ou 0 caso
; seja soma
; Autor: Gabriele Jandres, Lucas Moreno e Victor Cardoso
;----------------------------------------------------------------------

; constantes de hardware
DISPLAY EQU 0

;----------------------------------------------------------------------

ORG 300

VAR1:  DB 5  ; primeira parcela da operação
VAR2:  DB 3  ; segunda parcela da operação

; exemplo com overflow na multiplicação
;VAR1:  DB 26
;VAR2:  DB 10

PTR_VAR2: DW VAR2 ; endereço de VAR2
PTR_VAR1: DW VAR1 ; endereço de VAR1

; indicadores de operação
SOMA:  DB 0  ; indicador que a operação será uma soma
MULT:  DB 1  ; indicador que a operação será uma multiplicação
OVER:  DB 0  ; variável que irá indicar se houve overflow

I:     DB 0 ; contador para loop de multiplicação

RES: DW 0    ; variável que armazenará o resultado da operação
PTR_RES: DW RES ; ponteiro para a variável resultado

; variáveis da rotina
SP: DW 0     ; apontador de pilha
AUX: DW 0    ; variável auxiliar usada na rotina
OP: DW 0    ; variável auxiliar usada na rotina
PTR: DW 0    ; ponteiro auxiliar para o endereço do resultado retirado da pilha
PTR1: DW 0    ; ponteiro auxiliar para a variável 1
PTR2: DW 0    ; ponteiro auxiliar para a variável 2
MOD_V1: DW 0  ; variável auxiliar para armazenar o módulo da variável 1
MOD_V2: DW 0  ; variável auxiliar para armazenar o módulo da variável 2

;----------------------------------------------------------------------

ORG 0

ROTINA:
       STS SP  ; guardamos o apontador de pilha na memória para podermos retornar depois

       ; salvamos qual operação deve ser realizada
       STA OP ; OP = ACC

       ; damos dois pops para retirar o endereço de retorno da stack da memória
       POP
       POP

       ; PTR1 = endereço de VAR1
       POP
       STA PTR1+1
       POP
       STA PTR1

       LDA @PTR1 ; ACC = VAR1
       STA MOD_V1 ; MOD_V1 = ACC = |VAR1|
       JN V1_NEGATIVA

CONTINUA_V1:

       ; PTR2 = endereço de VAR2
       POP
       STA PTR2+1
       POP
       STA PTR2

       LDA @PTR2 ; ACC = VAR2
       STA MOD_V2 ; MOD_V2 = ACC = |VAR2|
       JN V2_NEGATIVA

CONTINUA_V2:

       ; PTR = endereço de RES
       POP
       STA PTR+1
       POP
       STA PTR

       LDA OP ; verificamos qual operação deve ser executada
       JZ  ADICIONA ; pula para adiciona se o código da operação for 0
       JMP MULTIPLICA ; pula para multiplica se o código não for 0

; torna V1 positiva
V1_NEGATIVA:
        NOT
        ADD #1
        STA MOD_V1
        JMP CONTINUA_V1

; torna V2 positiva
V2_NEGATIVA:
        NOT
        ADD #1
        STA MOD_V2
        JMP CONTINUA_V1

ADICIONA:
       LDA @PTR2 ; ACC = VAR2
       ADD @PTR1 ; ACC = ACC + AUX = VAR2 + VAR1
       STA AUX ; AUX = ACC

       JC OVERFLOW_SOMA ; pula para overflow se houve overflow em 8 bits

CONTINUA_SOMA:
       LDA AUX+1
       ADC #0
       STA AUX+1

       JMP FIM_ROTINA

MULTIPLICA:
       LDA I ; ACC = I
       SUB MOD_V1 ; ACC = ACC - V1 = I - VAR1
       JN  LOOP ; pula para o loop enquanto o número de iterações I não for igual a VAR1

       LDA @PTR1
       XOR @PTR2 ; verifica os sinais de VAR1 e VAR2
       JN CONVERTE_RES ; pula pra converter o sinal do resultado caso os operandos tenham sinal trocado

       JMP FIM_ROTINA

CONVERTE_RES:
        ; invertendo os bits do resultado positivo da multiplicação
        LDA AUX
        NOT
        STA AUX
        LDA AUX+1
        NOT
        STA AUX+1

        ; adicionando 1
        LDA AUX
        ADD #1
        STA AUX
        LDA AUX+1
        ADC #0
        STA AUX+1

        JMP FIM_ROTINA

FIM_ROTINA:
       ; transferindo o resultado para RES
       LDS AUX
       STS @PTR

       LDA OVER    ; ACC = OVER
       OUT DISPLAY ; coloca o valor do acumulador no visor

       LDS SP
       RET

LOOP:
       LDA AUX ; ACC = AUX
       ADD MOD_V2 ; ACC = ACC + V2 = ACC + VAR2
       STA AUX ; AUX = ACC

       JC OVERFLOW_MULT ; pula para overflow se o carry foi ativo no momento da adição da parcela

CONTINUA_MULT:
       LDA AUX+1
       ADC MOD_V2+1
       STA AUX+1

       ; incrementando o contador
       LDA I ; ACC = I
       ADD #1 ; ACC = ACC + 1
       STA I ; I = ACC

       JMP MULTIPLICA

OVERFLOW_SOMA:
        LDA #1 ; ACC = 1 -> lê o valor 1
        STA OVER ; OVER = ACC = 1 -> atribui 1 à variável over para indicar que houve overflow
        JMP CONTINUA_SOMA ; continua fazendo a conta

OVERFLOW_MULT:
        LDA #1 ; ACC = 1 -> lê o valor 1
        STA OVER ; OVER = ACC = 1 -> atribui 1 à variável over para indicar que houve overflow
        JMP CONTINUA_MULT ; continua fazendo a conta

; programa principal de exemplo
INICIO:
       ; adicionando o endereço de RES na pilha
       LDA PTR_RES
       PUSH
       LDA PTR_RES+1
       PUSH

       ; adicionando o endereço de VAR2 na pilha
       LDA PTR_VAR2
       PUSH
       LDA PTR_VAR2+1
       PUSH

       ; adicionando o endereço de VAR1 na pilha
       LDA PTR_VAR1
       PUSH
       LDA PTR_VAR1+1
       PUSH

       LDA SOMA ; ACC = OPERAÇÃO
       JSR ROTINA

       HLT ; finaliza o programa
END    INICIO









        
