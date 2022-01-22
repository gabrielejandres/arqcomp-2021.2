;----------------------------------------------------------------------
; Programa: Cálculo do produto interno de dois vetores
; Descrição: O programa exibe no banner o valor hexadecimal correspondente ao valor do produto
; interno entre os vetores. No display é exibido 1, se houve overflow, ou 0, caso contrário
; Autor: Gabriele Jandres, Lucas Moreno e Victor Cardoso
;----------------------------------------------------------------------

; constantes de hardware
DISPLAY EQU 0
BANNER  EQU 2
LIMPABANNER EQU 3

;----------------------------------------------------------------------

ORG 900
V:   	DB 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ; primeiro vetor

ORG 1000

U:   	DB 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ; segundo vetor

; Exemplo com overflow
;U: DB 122, 210, 110, 250, 32, 8, 2, 2, 13, 5, 1, 8, 1, 1, 1, 2, 1, 8, 2, 2
;V: DB 117, 120, 200, 11, 45, 1, 11, 10, 4, 5, 7, 1, 1, 1, 4, 5, 7, 1, 1, 1

TAM:      DB 20      ; tamanho dos vetores
OVER:     DB 0       ; variável que irá indicar se houve overflow
CARACTERE:DB 0       ; variável que irá armazenar caracteres a serem impressos no banner
RES:      DW 0       ; variável que armazenará o produto interno
AUX:      DW 0       ; variável auxiliar para calcular os produtos
SP:       DW 0       ; apontador de pilha

; variáveis de controle de iterações
I:   	DB 0
J:      DB 0

; ponteiros
PTRV: 	DW V ; ponteiro para o primeiro vetor
PTRU: 	DW U ; ponteiro para o segundo vetor

; módulos de U[I] e V[I]
MOD_U:  DW 0
MOD_V:  DW 0

;----------------------------------------------------------------------

ORG 0

INICIO: 
 	LDA I ; ACC = I
     	SUB TAM ; ACC = ACC - TAM
     	JN  INICIO_ITERACAO ; pula para iteração enquanto não chegarmos em TAM iterações
        JMP PRINTABANNER ; ao terminar pula pra etapa de printar no banner

INICIO_ITERACAO:
        ; armazena o módulo de U[I]
        LDA @PTRU ; ACC = *PTRU
        STA MOD_U ; MOD_U = ACC = |*PTRU|
        JN U_NEGATIVO

CONTINUA_U:
        ; armazena o módulo de V[I]
        LDA @PTRV ; ACC = *PTRV
        STA MOD_V ; MOD_V = ACC = |*PTRV|
        JN V_NEGATIVO

ITERACAO:
        LDA J ; ACC = J
        SUB MOD_U ; ACC = ACC - |*PTRU|
        JN PROD ; pula para PROD se for negativo, isto é, se ainda não fizemos todas as adições necessárias
        ; para chegar no resultado da multiplicação

        LDA @PTRU
        XOR @PTRV ; verifica os sinais de U[I] e V[I]
        JN SUBTRACAO ; pula pra subtração caso os operandos tenham sinal trocado (parcela negativa)

SOMA:
        ; adicionando o valor de AUX no produto interno, já que é uma parcela
        LDA RES ; ACC = RES
        ADD AUX ; ACC = ACC + AUX
        STA RES ; RES = ACC

        LDA RES+1
        ADC #0
        STA RES+1

        JC OVERFLOW ; pula para overflow se o carry foi ativo no momento da adição da parcela

        JMP CONTINUA

SUBTRACAO:
        ; subtraindo o valor de AUX no produto interno, já que é uma parcela
        LDA RES ; ACC = RES
        SUB AUX ; ACC = ACC - AUX
        STA RES ; RES = ACC

        LDA RES+1
        SBC #0
        STA RES+1

        JC OVERFLOW ; pula para overflow se o carry foi ativo no momento da adição da parcela

CONTINUA:
        ; zerando AUX para a próxima iteração
        LDA #0
        STA AUX

        ; incrementando o ponteiro de U
        LDA PTRU
        ADD #1
        STA PTRU

INC:
        ; incrementando I
        LDA I
     	ADD #1
     	STA I

        ; zerando J para a próxima iteração
        LDA #0
        STA J

        ; incrementando o ponteiro de V
        LDA PTRV
        ADD #1
        STA PTRV

     	JMP INICIO ; volta para o inicio para testar se temos mais iterações

; torna U positivo
U_NEGATIVO:
        NOT
        ADD #1
        STA MOD_U
        JMP CONTINUA_U

; torna V positivo
V_NEGATIVO:
        NOT
        ADD #1
        STA MOD_V
        JMP ITERACAO

PROD:
        ; somando o valor de V[I] em AUX para chegarmos em V[I] * U[I]
        LDA AUX ; ACC = AUX
        ADD MOD_V ; ACC = ACC + *PTRV
        STA AUX ; AUX = ACC

        LDA AUX+1
        ADC #0
        STA AUX+1

        ; incrementando J
        LDA J
        ADD #1
        STA J

        JMP ITERACAO ; pula para a próxima iteração

OVERFLOW:
        LDA #1 ; ACC = 1 -> lê o valor 1
        STA OVER ; OVER = ACC = 1 -> atribui 1 à variável over para indicar que houve overflow
        JMP CONTINUA

PRINTABANNER:
        OUT LIMPABANNER ; limpa o banner

        ; imprime no banner os bits de RES+1 (2 primeiros dígitos)
        LDA RES+1
        PUSH
        JSR PARTE1
        LDA RES+1
        PUSH
        LDA CARACTERE
        PUSH
        JSR PARTE2

        ; imprime no banner os bits de RES (2 últimos dígitos)
        LDA RES
        PUSH
        JSR PARTE1
        LDA RES
        PUSH
        LDA CARACTERE
        PUSH
        JSR PARTE2

        JMP FIM

PARTE1:
        STS SP ; guardamos o apontador de pilha na memória para podermos retornar depois

        ; damos dois pops para retirar o endereço de retorno da stack da memória
        POP
        POP

        ; retiramos 8 bits do endereço da pilha
        POP

        ; fazemos shifts para a direita
        SHR
        SHR
        SHR
        SHR

        ; guardamos no acumulador o valor shiftado que corresponde ao caractere que desejamos
        STA CARACTERE

        ; subtraímos 10 do caractere para verificar se eh um decimal de 0 a 9 ou uma letra
        SUB #10
        JP IMPRIMELETRA ; se a subtração for positiva temos uma letra

        ; se não for letra, eh decimal
        LDA CARACTERE ; ACC = CARACTERE
        ADD #30H      ; somamos 30 porque os decimais de 0 a 9 correspondem aos hexas de 30 a 39
        OUT BANNER    ; mostramos o caractere decimal no banner

        JMP RETORNO

PARTE2:
        STS SP ; guardamos o apontador de pilha na memória para podermos retornar depois

        ; damos dois pops para retirar o endereço de retorno da stack da memória
        POP
        POP

        ; retiramos 8 bits do endereço da pilha
        POP

        ; fazemos shifts para a esquerda
        SHL
        SHL
        SHL
        SHL

        ; guardamos no acumulador o valor que corresponde ao caractere que desejamos
        STA CARACTERE
        POP
        SUB CARACTERE
        STA CARACTERE

        ; subtraímos 10 do caractere para verificar se eh um decimal de 0 a 9 ou uma letra
        SUB #10
        JP IMPRIMELETRA ; se a subtração for positiva temos uma letra

        ; se não for letra, eh decimal
        LDA CARACTERE ; ACC = CARACTERE
        ADD #30H      ; somamos 30 porque os decimais de 0 a 9 correspondem aos hexas de 30 a 39
        OUT BANNER    ; mostramos o caractere decimal no banner

        JMP RETORNO

IMPRIMELETRA:
        LDA CARACTERE
        ADD #37H ; convertendo para ascii se não for um decimal de 0 a 9
        OUT BANNER

        JMP RETORNO

RETORNO:
        LDS SP ; recuperamos o endereço de retorno
        RET

FIM:
        LDA OVER ; ACC = OVER para saber se houve ou não overflow
        OUT DISPLAY ; coloca o valor do acumulador no visor

        HLT ; finaliza o programa
END     INICIO
