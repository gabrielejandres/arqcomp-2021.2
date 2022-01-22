;---------------------------------------------------
; Programa: Conversão e impressão de variável no banner
; Descrição: O programa exibe no banner o valor decimal do
; parâmetro recebido na pilha
; Parâmetros: O endereço de uma variável de 32 bits com sinal
; Autor: Gabriele Jandres, Lucas Moreno e Victor Cardoso
; Link do algoritmo utilizado: https://pubweb.eng.utah.edu/~nmcdonal/Tutorials/BCDTutorial/BCDConversion.html
;---------------------------------------------------

ORG 500h
SP: DW 0    ;stack pointer
I:  DB 0    ;variável de incremento do loop do bitshift
K:  DB 0    ;variável de incremento do loop do bitshift
B:  DB 0    ;variável de incremento do loop do banner
NUMERO: DS 10 ;variável que recebe a resposta

; variáveis que recebem as partições do número
; Se lê da seguint forma: n = 162 -> 'VAR4[0]'+'VAR3[0]'+'VAR2[0]'+'VAR[162]'

VAR4: DB 0h
VAR3: DB 0h
VAR2: DB 0h
VAR1: DB 0A2h

;ponteiros para as variáveis que compõe o número

PTR_VAR1: DW VAR1
PTR_VAR2: DW VAR2
PTR_VAR3: DW VAR3
PTR_VAR4: DW VAR4

;ponteiros auxiliares utilizados para guardar os endereços das variáveis

PTR_AUX1: DW 0
PTR_AUX2: DW 0
PTR_AUX3: DW 0
PTR_AUX4: DW 0

PTR: DW NUMERO ;pointero para o endereço da resposta
PTR_VETOR: DW NUMERO ;ponteiro para o "inicio do número"



ORG 0

ROTINA:
  STS SP  ; guardamos o apontador da pilha na memória para podermos retornar depois

  POP
  POP

  ; PTR_VAR4 = endereço de VAR1
  POP
  STA PTR_AUX1+1
  POP
  STA PTR_AUX1

  ; PTR_VAR3 = endereço de VAR2
  POP
  STA PTR_AUX2+1
  POP
  STA PTR_AUX2

  ; PTR_VAR2 = endereço de VAR3
  POP
  STA PTR_AUX3+1
  POP
  STA PTR_AUX3

  ; PTR_VAR1 = endereço de VAR4
  POP
  STA PTR_AUX4+1
  POP
  STA PTR_AUX4

  OUT 3  ;apaga o valor atual no banner

FOR:    ;i=0; i<32 (Tamanho da variável);
  LDA I
  SUB#32
  JZ BANNER ;quando I for igual a 32, podemos começar a gerar a resposta

FOREACH:   ; para cada coluna será adicionado +3 se a coluna for >= 5
  LDA K
  SUB #10
  JZ  BITSHIFT  ; Quando a k chegar a 10, redireciona para o bitshift

  LDA K    ;incrementa o k
  ADD #1
  STA K

  LDA @PTR      ; enquanto a coluna nao for igual a 5, passa para a próxima posição do vetor
  SUB #5
  JN ANDA_VETOR

  LDA @PTR   ; adiciona 3 ao vetor na posição j
  ADD #3
  STA @PTR

ANDA_VETOR:     ; passa o ponteiro para a próxima posição do vetor
  LDA PTR
  ADD #1
  STA PTR
  JMP FOREACH

BITSHIFT:           ;reseta k
  LDA #0
  STA K
  LDA PTR_VETOR     ;aponta para o "inicio" do vetor resposta
  STA PTR

LOOP:
  LDA K      ; percorre apenas 9 das 10 posições do vetor, porque o último tem um tratamento especial
  SUB #9
  JZ CASO_ESPECIAL

  LDA K  ; incrementa k
  ADD #1
  STA K

  LDA @PTR ; realiza bitshift do valor apontado pelo ponteiro
  SHL
  STA @PTR

  LDA PTR  ; passa para a próxima posição do vetor
  ADD #1
  STA PTR

  LDA @PTR ; checa se o primeiro algarismo do bloco é 1, se não for, continua a dar shift
  AND #8
  JZ LOOP

  LDA @PTR ;se for, retira 1000 [(1)000] -> 1000 [(0)000]
  SUB #8
  STA @PTR

  LDA PTR  ;volta pra posição anterior
  SUB #1
  STA PTR

  LDA @PTR ; [100(0)] 0000 -> [100(1)] 0000
  ADD #1
  STA @PTR

  LDA PTR ; passa para a próxima posição
  ADD #1
  STA PTR

  JMP LOOP

CASO_ESPECIAL:

  LDA @PTR ; realiza bitshift do valor apontado pelo ponteiro
  SHL
  STA @PTR

  LDA @PTR_VAR4   ;verifica se o bit mais alto é 1
  AND #128
  JZ TRATA_VAR4

  LDA @PTR
  ADD #1
  STA @PTR


; Aqui começa o bitshift da parte própria que passamos para o algoritmo (binary)

TRATA_VAR4:  ;bitshift da primeira parte dos bits mais significativos do binary -> (0100) 0010 0101 1100

  LDA @PTR_VAR4
  SHL
  STA @PTR_VAR4

  LDA @PTR_VAR3  ;verifica se o bit mais alto é 1
  AND #128
  JZ TRATA_VAR3

  LDA @PTR_VAR4
  ADD #1
  STA @PTR_VAR4


TRATA_VAR3:  ;bitshift da segunda parte dos bits mais significativos do binary -> 0100 (0010) 0101 1100

  LDA @PTR_VAR3
  SHL
  STA @PTR_VAR3

  LDA @PTR_VAR2  ;verifica se o bit mais alto é 1
  AND #128
  JZ TRATA_VAR2

  LDA @PTR_VAR3
  ADD #1
  STA @PTR_VAR3


TRATA_VAR2:  ;bitshift da primeira parte dos bits menos significativos do binary -> 0100 0010 (0101) 1100

  LDA @PTR_VAR2
  SHL
  STA @PTR_VAR2

  LDA @PTR_VAR1  ;verifica se o bit mais alto é 1
  AND #128
  JZ TRATA_VAR1

  LDA @PTR_VAR2
  ADD #1
  STA @PTR_VAR2

TRATA_VAR1: ;bitshift da segunda parte dos bits menos significativos do binary -> 0100 0010 0101 (1100)

  LDA @PTR_VAR1
  SHL
  STA @PTR_VAR1

RESETA_LOOP:

  LDA I   ; realizamos tudo do loop do I e encrementamos ele
  ADD #1
  STA I

  LDA #0 ; como chegamos no fim do loop do k, resetamos ele
  STA K

  LDA PTR_VETOR
  STA PTR

  JMP FOR  ;volta para o início do corpo do for


BANNER:

  LDA B
  ADD #1
  STA B

  LDA @PTR ; adiciona  30 em hexadecimal (48 em decimal) ao valor de cada número dos vetores para transformar em ascii
  ADD #30H
  OUT 2

  LDA PTR  ; passa para o próximo endereço do vetor
  ADD #1
  STA PTR

  LDA B    ; enquanto B nao chegar em 10, o loop continua
  SUB #10
  JNZ BANNER

  LDS SP
  RET     ; retorna para a main

INICIO:
  ; adicionando endereço de VAR4 na pilha
  LDA PTR_VAR4
  PUSH
  LDA PTR_VAR4+1
  PUSH

  ; adicionando endereço de VAR3 na pilha
  LDA PTR_VAR3
  PUSH
  LDA PTR_VAR3+1
  PUSH

  ; adicionando endereço de VAR2 na pilha
  LDA PTR_VAR2
  PUSH
  LDA PTR_VAR2+1
  PUSH

  ; adicionando endereço de VAR1 na pilha
  LDA PTR_VAR1
  PUSH
  LDA PTR_VAR1+1
  PUSH

  JSR ROTINA
  HLT

END INICIO





























