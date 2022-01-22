;---------------------------------------------------
; Programa: Inserção de um elemento na lista encadeada ordenada de strings
; Descrição: O programa conta com uma rotina de inserção é responsável por inserir um novo elemento
; na lista, de forma que ela continue ordenada. Ao final, ele exibe, em ordem, no console as chaves
; da estrutura
; Parâmetros: Endereço inicial dessa estrutura e o endereço de um elemento para ser inserido nela
; são passados na pilha
; Retorno da rotina: Retorna na pilha o endereço inicial da estrutura
; Autor: Gabriele Jandres, Lucas Moreno e Victor Cardoso
;---------------------------------------------------

ORG 1000

; elementos da estrutura
ELEMENTO1: STR "ABCDEFGH"
           DW ELEMENTO2

ELEMENTO2: STR "IJKLMNOP"
           DW ELEMENTO3

ELEMENTO3: STR "PABBCCDD"
           DW 0 ; o ponteiro nulo indica que a estrutura chegou ao fim

NOVOELEMENTO:  STR "NOVOABCD" ; novo elemento a ser inserido na lista
               DW 0

PEST: DW ELEMENTO1    ; ponteiro para a primeira cadeia de caracteres
PNOVO:DW NOVOELEMENTO ; ponteiro para o novo elemento
J:    DB 0            ; variável de controle de iteração
QUEBRALINHA: DB 0Ah   ; variável para quebra de linha no console
TP:    DW 0           ; variável temporária utilizada para copiar endereços
PTR:     DW 0         ; ponteiro auxiliar

; variáveis da rotina de inserção
SP:      DW 0           ; stack pointer
PE:      DW 0           ; ponteiro auxiliar para o endereço da estrutura
PN:      DW 0           ; ponteiro auxiliar para o novo elemento
PINICIO: DW 0           ; ponteiro para o início da estrutura
PANT:    DW 0           ; ponteiro para o elemento anterior
PPROX:   DW 0           ; ponteiro para o próximo elemento
TEMP:    DW 0           ; variável temporária utilizada para copiar endereços

; variáveis da rotina de comparação
SP2:     DW 0           ; stack pointer
AUX:     DW 0           ; variável auxiliar
TAM:     DB 8           ; tamanho das cadeias de caracteres
I:       DB 0           ; variável de controle de iterações
MENOSUM: DB -1          ; rótulo para retornar -1 no acc
RES:     DB 0           ; variável auxiliar para guardar o resultado da comparação
PAUXE:   DW 0           ; ponteiro auxiliar para guardar o endereço inicial da estrutura
PAUXN:   DW 0           ; ponteiro auxiliar para guardar o endereço do novo elemento

;----------------------------------------------------------------------

ORG 0
ROTINA_INSERE:
       ; guardamos o apontador de pilha na memória para podermos retornar depois
       POP
       STA SP
       POP
       STA SP+1

       ; PN = endereço do novo elemento (CADEIA2)
       POP
       STA PN+1
       POP
       STA PN

       ; PE = endereço inicial da estrutura (CADEIA1)
       POP
       STA PE+1
       POP
       STA PE

       ; salvando o endereço inicial da estrutura
       LDS PE
       STS PINICIO

       ; adicionando novamente na pilha para a rotina de comparação
       LDA PE
       PUSH
       LDA PE+1
       PUSH

       ; adicionando o endereço do novo elemento na pilha
       LDA PN
       PUSH
       LDA PN+1
       PUSH

       JSR ROTINA_COMPARA

       JMP CHECA_RES

CHECA_RES:
       STA RES   ; se o resultado da comparação for 1, devo continuar procurando a posição de inserção
       SUB #1
       JZ BUSCA

       JMP INSERE ; se for -1, devo inserir antes da posição atual

BUSCA:
       ; salvando o endereço atual como anterior
       LDA PE
       STA PANT
       LDA PE+1
       STA PANT+1

       ; pegando o apontador da posição atual
       LDA PE
       ADD #8
       STA PE
       LDA PE+1
       ADC #0
       STA PE+1

       ; pegando o endereço que está no apontador da posição atual
       LDA @PE
       STA PPROX
       LDA PE
       ADD #1
       STA TEMP
       LDA PE+1
       ADC #0
       STA TEMP+1
       LDA @TEMP
       STA PPROX+1

       ; salvando o próximo endereço como atual
       LDA PPROX
       STA PE
       LDA PPROX+1
       STA PE+1

       ; checando se o ponteiro eh 0 porque se for chegamos no fim da estrutura
       LDA PPROX
       JZ INSERE

       ; adiciono na pilha para a rotina de comparação
       LDA PPROX
       PUSH
       LDA PPROX+1
       PUSH

       ; adicionando o endereço do novo elemento na pilha
       LDA PN
       PUSH
       LDA PN+1
       PUSH

       ; chamando a rotina de comparação com a próxima cadeia e o novo elemento
       JSR ROTINA_COMPARA

       JMP CHECA_RES

INSERE:
       ; se quero inserir e o anterior eh 0 quer dizer que vamos inserir no início
       LDA PANT
       JZ INSERE_INICIO

       ; pegando o apontador do anterior e salvando em PANT
       LDA PANT
       ADD #8
       STA PANT
       LDA PANT+1
       ADC #0
       STA PANT+1

       ; salvando no endereço apontado por PANT o endereço pro novo elemento
       LDS PN
       STS @PANT

ATUALIZA_NOVO:
       ; pegando o apontador do novo elemento e salvando em PN
       LDA PN
       ADD #8
       STA PN
       LDA PN+1
       ADC #0
       STA PN+1

       ; salvando no endereço apontado por PN o endereço pra posição atual da estrutura
       LDS PE
       STS @PN

       JMP FIM_INSERE

INSERE_INICIO:
       ; salvando PN no apontador PINICIO
       LDS PN
       STS PINICIO

       JMP ATUALIZA_NOVO

FIM_INSERE:
       LDS SP

       ; adicionando o endereço inicial da estrutura na pilha
       LDA PINICIO
       PUSH
       LDA PINICIO+1
       PUSH

       LDA SP+1
       PUSH
       LDA SP
       PUSH

       RET

ROTINA_COMPARA:
       STS SP2 ; guardamos o apontador de pilha na memória para podermos retornar depois

       ; damos dois pops para retirar o endereço de retorno da stack da memória
       POP
       POP

       ; PAUXN = endereço do novo elemento (CADEIA2)
       POP
       STA PAUXN+1
       POP
       STA PAUXN

       ; PAUXE = endereço inicial da estrutura (CADEIA1)
       POP
       STA PAUXE+1
       POP
       STA PAUXE

       ; zerando I
       LDA #0
       STA I

       JMP ITERACAO

ITERACAO:
       ; vai comparar as cadeias enquanto não chegar em 8, que eh o tamanho delas
       LDA I
       SUB TAM
       JN LOOP

LOOP:
       ; lendo caractere da primeira cadeia (estrutura)
       LDA @PAUXE ; ACC = *PAUXE
       STA AUX    ; AUX = ACC
       ; OUT 2 ; para testar no banner

       ; lendo caractere da segunda cadeia (novo elemento)
       LDA @PAUXN ; ACC = *PAUXN
       ; OUT 2 ; para testar no banner

       ; subtraímos os valores hexas de cada caractere
       SUB AUX    ; ACC = ACC - AUX = *PAUXE - *PAUXN

       JN NOVO_MENOR ; se a cadeia do novo elemento for menor posso inserir na frente dele
       JZ ZERO
       JMP EST_MENOR  ; nesse caso, a string da estrutura vem antes da string do novo elemento
       ; no alfabeto, continuo procurando até achar a posição de inserção (engloba o caso em que
       ; são iguais, porque considera que a atual eh menor e devo inserir depois dela)

EST_MENOR:
       ; nesse caso a cadeia da estrutura é menor, então devo continuar procurando a posição de
       ; inserção
       LDA #1
       JMP FIM_COMPARA

NOVO_MENOR:
       ; nesse caso, CADEIA2 vem antes de CADEIA1 no alfabeto, então tenho que inserir na posição
       ; à frente na estrutura
       LDA MENOSUM
       JMP FIM_COMPARA

ZERO:
       ; incrementando o ponteiro da estrutura (andando na string)
       LDA PAUXE
       ADD #1
       STA PAUXE

       ; incrementando o ponteiro do novo elemento (andando na string)
       LDA PAUXN
       ADD #1
       STA PAUXN

       ; incrementando I (I++)
       LDA I
       ADD #1
       STA I

       JMP ITERACAO

FIM_COMPARA:
       LDS SP2
       RET

IMPRIME_CADEIAS:
       LDA J
       SUB TAM
       JN IMPRIME_LINHA

       ; pegando o apontador da posição atual na estrutura
       LDA PEST
       ADD #8
       STA PEST
       LDA PEST+1
       ADC #0
       STA PEST+1

       ; pegando o apontador da posição atual para imprimir o próximo elemento
       LDA @PEST
       STA PTR
       LDA PEST
       ADD #1
       STA TP
       LDA PEST+1
       ADC #0
       STA TP+1
       LDA @TP
       STA PTR+1

       ; atualizando a posição atual
       LDA PTR
       STA PEST
       LDA PTR+1
       STA PEST+1

       ; quebra a linha no console
       LDA #2
       TRAP QUEBRALINHA

       ; reiniciando o contador J
       LDA #0
       STA J

       ; enquanto nao chegar no fim da estrutura imprime as linhas
       LDA PTR
       JNZ IMPRIME_LINHA

       ; se chegou aqui tudo já foi impresso e finaliza o programa
       JMP FIM

IMPRIME_LINHA:
       LDA #2
       TRAP @PTR

       ; andando na string
       LDA PTR
       ADD #1
       STA PTR
       LDA PTR+1
       ADC #0
       STA PTR+1

       ; incrementando J
       LDA J
       ADD #1
       STA J

       JMP IMPRIME_CADEIAS

INICIO:
       ; OUT 3 ; para testar no banner
       ; adicionando o endereço inicial da estrutura na pilha
       LDA PEST
       PUSH
       LDA PEST+1
       PUSH

       ; adicionando o endereço do novo elemento na pilha
       LDA PNOVO
       PUSH
       LDA PNOVO+1
       PUSH

       JSR ROTINA_INSERE

       ; salvando o endereço de início da estrutura que pode ter sido mudado com a inserção
       POP
       STA PEST+1
       POP
       STA PEST

       ; copio o valor de PEST para o auxiliar PTR
       LDA PEST
       STA PTR
       LDA PEST+1
       STA PTR+1

       JMP IMPRIME_CADEIAS

FIM:
       HLT ; finaliza o programa
END    INICIO








