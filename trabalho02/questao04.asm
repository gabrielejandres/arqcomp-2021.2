; --------------------------------------------------------------------
; Programa: Comparação alfabética de duas cadeias de caracteres
; Descrição: O programa conta com uma rotina para comparar as duas cadeias de caracteres
; Parâmetros: Os endereços das cadeias são passados na pilha
; Retorno da rotina:
  ; * 0 em acc se CADEIA1 = CADEIA2
  ; * 1 em acc se CADEIA1 < CADEIA2 (a primeira vem antes no alfabeto)
  ; * -1 em acc se CADEIA2 < CADEIA1 (a segunda vem antes no alfabeto)
; Autor: Gabriele Jandres, Lucas Moreno e Victor Cardoso
; ---------------------------------------------------------------------

ORG 300

; variáveis do programa de exemplo
CADEIA1: STR    "Amor"
         DB     0       ; CADEIA1 termina com NULL
CADEIA2: STR    "Amora"
         DB     0       ; CADEIA2 termina com NULL
PTR1:    DW     CADEIA1 ; ponteiro para a primeira cadeia de caracteres
PTR2:    DW     CADEIA2 ; ponteiro para a segunda cadeia de caracteres

; variáveis da rotina
SP:      DW 0           ; stack pointer
PAUX1:   DW 0           ; ponteiro auxiliar para guardar endereços da primeira cadeia
PAUX2:   DW 0           ; ponteiro auxiliar para guardar endereços da segunda cadeia
AUX:     DW 0           ; variável auxiliar para guardar o valor hexadecimal de um caractere
NULO:    DB 0           ; variável que indica se chegou o fim de alguma string
MENOSUM: DB -1

;----------------------------------------------------------------------

ORG 0
ROTINA:
       STS SP  ; guardamos o apontador de pilha na memória para podermos retornar depois

       ; damos dois pops para retirar o endereço de retorno da stack da memória
       POP
       POP

       ; PAUX2 = endereço de CADEIA2
       POP
       STA PAUX2+1
       POP
       STA PAUX2

       ; PAUX1 = endereço de CADEIA1
       POP
       STA PAUX1+1
       POP
       STA PAUX1

       JMP LOOP

LOOP:
       LDA @PAUX2 ; lê um caractere da cadeia 2
       OR #0      ; verifica se eh o caractere nulo
       JZ NULL2

       LDA @PAUX1 ; lê um caractere da cadeia 1
       OR #0      ; verifica se eh o caractere nulo
       JZ NULL1

       ; lendo caractere da primeira cadeia
       LDA @PAUX1 ; ACC = *PAUX1
       STA AUX    ; AUX = ACC

       ; lendo caractere da segunda cadeia
       LDA @PAUX2 ; ACC = *PAUX2

       ; subtraímos os valores hexas de cada caractere
       SUB AUX    ; ACC = ACC - AUX = *PAUX1 - *PAUX2

       JN CADEIA2_MENOR
       JZ ZERO
       JMP CADEIA1_MENOR

NULL2:
       LDA #1
       STA NULO   ; armazeno a informação de que a cadeia 2 acabou

       LDA @PAUX1 ; lê um caractere da cadeia 1
       OR #0      ; verifica se eh o caractere nulo
       JZ IGUAIS

       JMP CADEIA2_MENOR

NULL1:
       LDA #1
       STA NULO   ; armazeno a informação de que a cadeia 1 acabou

       LDA @PAUX2 ; lê um caractere da cadeia 2
       OR #0      ; verifica se eh o caractere nulo
       JZ IGUAIS

       JMP CADEIA1_MENOR

IGUAIS:
       LDA #0
       JMP FIM

CADEIA2_MENOR:
       ; nesse caso, CADEIA2 vem antes de CADEIA1 no alfabeto
       LDA MENOSUM
       JMP FIM

CADEIA1_MENOR:
       ; nesse caso, CADEIA1 vem antes de CADEIA2 no alfabeto
       LDA #1
       JMP FIM

ZERO:
       ; incrementando o ponteiro da CADEIA1
       LDA PAUX1
       ADD #1
       STA PAUX1

       ; incrementando o ponteiro da CADEIA2
       LDA PAUX2
       ADD #1
       STA PAUX2

       JMP LOOP

FIM:
       LDS SP
       RET

; programa principal de exemplo
INICIO:
       ; adicionando o endereço de CADEIA1 na pilha
       LDA PTR1
       PUSH
       LDA PTR1+1
       PUSH

       ; adicionando o endereço de CADEIA2 na pilha
       LDA PTR2
       PUSH
       LDA PTR2+1
       PUSH

       JSR ROTINA
       OUT 0 ; exibe no visor o resultado guardado no acumulador
       HLT ; finaliza o programa
END INICIO







