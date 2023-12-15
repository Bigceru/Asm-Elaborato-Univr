.section .data

pilot_0_str:
    .string   "Pierre Gasly\0"
pilot_1_str:
    .string   "Charles Leclerc\0"
pilot_2_str:
    .string   "Max Verstappen\0"
pilot_3_str:                       
    .string   "Lando Norris\0"
pilot_4_str:
    .string   "Sebastian Vettel\0"
pilot_5_str:
    .string   "Daniel Ricciardo\0"
pilot_6_str: 
    .string   "Lance Stroll\0"
pilot_7_str:
    .string   "Carlos Sainz\0"
pilot_8_str:
    .string   "Antonio Giovinazzi\0"
pilot_9_str:
    .string   "Kevin Magnussen\0"
pilot_10_str:
    .string  "Alexander Albon\0"
pilot_11_str:
    .string  "Nicholas Latifi\0"
pilot_12_str:
    .string  "Lewis Hamilton\0"
pilot_13_str:
    .string  "Romain Grosjean\0"
pilot_14_str:
    .string  "George Russell\0"
pilot_15_str:
    .string  "Sergio Perez\0"
pilot_16_str:
    .string  "Daniil Kvyat\0"
pilot_17_str:
    .string  "Kimi Raikkonen\0"
pilot_18_str:
    .string  "Esteban Ocon\0"
pilot_19_str:
    .string  "Valtteri Bottas\0"

invalid_pilot_str:	
.string "Invalid"

stringa_virgola:
.ascii ","

stringa_invio:
.ascii "\n"

contatoreCaratteri:
.long 0

count:
.int 0

num1_len:
.long 0

flag:
.int 1

record_pilota:
.long 0

id:
.int 20

rpmMax:
.long 0

tempMax:
.long 0

velocitàMax:
.long 0

velocitàMedia:
.long 0

# stringhe per l'output
intToPrint:
.ascii "00000\0"

intToPrint_len:
.long 0

rpm_long:
.long 0

temperatura_long:
.long 0

velocità_long:
.long 0

id_str:
.ascii "\0\0\0"

temp_str:
.ascii "\0\0\0\0\0\0\0\0\0\0\0"

temp_str_len:
.long 0

# stringhe soglia giri motore
LOW:
.ascii "LOW"

MEDIUM:
.ascii "MEDIUM"

HIGH:
.ascii "HIGH"


.section .text
    .global telemetry

telemetry:

# ##### #
# LEGGO #
# ##### #

movl 4(%esp), %esi      # indirizzo stringa input
movl 8(%esp), %edi      # indirizzo stringa output

# BACKUP Stack
pushl %eax
pushl %ebx
pushl %ecx
pushl %edx

xorl %eax, %eax
xorl %ebx, %ebx
xorl %ecx, %ecx
xorl %edx, %edx

ciclo_lettura:
    movb (%esi, %ecx), %al   # scorro la stringa con base + spiazzamento
    cmpb $0, %al    # controllo di non aver letto il carattere \0
    je fine_ciclo_lettura

    # ho letto un carattere (%al)
    cmpl $20, id    # se ho già trovato l'id
    jne leggi_dati
    call leggi_nome
    movl $0, count

    # controllo se ci sono stati errori nel trovare l'id del pilota
    cmpl $0, flag
    je end_program

    xorl %edx, %edx
    xorl %ebx, %ebx

    leggi_dati:
        cmpb $44, %al   # controllo se ho letto una virgola
        je inc_count
        cmpb $10, %al   # controllo se ho letto \n
        je letto_invio

        # in base al count so cosa sto leggendo
        cmpb $0, count
        je input_tempo

        cmpb $1, count
        je input_id

        cmpb $2, count
        je input_velocità

        cmpb $3, count
        je input_rpm

        cmpb $4, count
        je input_temperatura

        input_tempo:
            leal temp_str, %ebx     # prendo l'indirizzo della stringa del tempo
            movb %al, (%ebx, %edx)
            incl %edx
            incl temp_str_len   # incremento il contatore dei caratteri
            jmp input_fine


        input_id:
            leal id_str, %ebx     # prendo l'indirizzo della stringa dell'id
            movb %al, (%ebx, %edx)
            incl %edx
            jmp input_fine


        input_velocità:
            pushl %ecx      # backup %ecx
            xorl %ecx, %ecx
            subb $48, %al   # converto il carattere in intero
            movb %al, %cl

            # moltiplico velocità_long * 10 (faccio spazio al nuovo intero)
            movl velocità_long, %eax
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in velocità_long
            addl %ecx, %eax
            movl %eax, velocità_long

            popl %ecx   # restore ecx

            jmp input_fine


        input_rpm:
            pushl %ecx      # backup %ecx
            xorl %ecx, %ecx
            subb $48, %al   # converto il carattere in intero
            movb %al, %cl

            # moltiplico velocità_long * 10 (faccio spazio al nuovo intero)
            movl rpm_long, %eax
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in velocità_long
            addl %ecx, %eax
            movl %eax, rpm_long

            popl %ecx   # restore ecx

            jmp input_fine


        input_temperatura:
            pushl %ecx      # backup %ecx
            xorl %ecx, %ecx
            subb $48, %al   # converto il carattere in intero
            movb %al, %cl

            # moltiplico velocità_long * 10 (faccio spazio al nuovo intero)
            movl temperatura_long, %eax
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in velocità_long
            addl %ecx, %eax
            movl %eax, temperatura_long

            popl %ecx   # restore ecx

            jmp input_fine


        inc_count:  # incrementa il contatore che segna dove siamo arrivati a leggere
            incl count
            xorl %edx, %edx
            xorl %ebx, %ebx
            jmp input_fine

        letto_invio:
            # confronto gli id e stampo l'eventuale riga giusta
            call idCompare

            # resetta
            movl $0, temp_str_len
            movl $0, rpm_long
            movl $0, temperatura_long
            movl $0, velocità_long
            movl $000, id_str
            movl $0, count      # contatore delle virgole
            xorl %edx, %edx
            xorl %ebx, %ebx

    input_fine:
        incl %ecx

jmp ciclo_lettura

fine_ciclo_lettura:
    # controllo di aver trovato il pilota corrispondente, altrimenti stampo il messaggio di errore e termino il programma
    cmpl $20, id
    jne output_finale
    # stampo il messaggio di errore
    leal invalid_pilot_str, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $7, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    jmp end_program


# ############################################################################## #
# output ultima stringa con <rpm max>,<temp max>,<velocità max>,<velocità media> #
# ############################################################################## #
output_finale:
    # OUTPUT rpm max
    movl rpmMax, %ecx   # passo in ecx il numero da convertire
    call itoa

    leal intToPrint, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl intToPrint_len, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # stampo la virgola
    leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # OUTPUT temp max
    movl tempMax, %ecx   # passo in ecx il numero da convertire
    movl $0, intToPrint_len
    call itoa

    leal intToPrint, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl intToPrint_len, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # stampo la virgola
    leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # OUTPUT velocità max
    movl velocitàMax, %ecx   # passo in ecx il numero da convertire
    movl $0, intToPrint_len
    call itoa

    leal intToPrint, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl intToPrint_len, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # stampo la virgola
    leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # OUTPUT velocità Media
    xorl %edx, %edx
    xorl %ebx, %ebx
    movl record_pilota, %ebx
    movl velocitàMedia, %eax
    divl %ebx      # calcolo la velocità media
    movl %eax, velocitàMedia

    movl $0, intToPrint_len
    movl velocitàMedia, %ecx   # passo in ecx il numero da convertire
    call itoa

    leal intToPrint, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl intToPrint_len, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # stampo lo \n
    leal stringa_invio, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

end_program:
    # RESTORE Stack
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret


# funzione per leggere il nome
.type leggi_nome, @function
leggi_nome:
    movb (%esi, %ecx), %al   # scorro la stringa con base + spiazzamento
    cmpb $10, %al    # controllo di non aver letto il carattere \n
    je fine_lettura

    # cerco il pilota
    cmpl $0, count
    jnz pilot1
    leal pilot_0_str, %edx      # confronto con il pilota 0
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot1:
    # cerco il pilota
    cmpl $1, count
    jnz pilot2
    leal pilot_1_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot2:
    # cerco il pilota
    cmpl $2, count
    jnz pilot3
    leal pilot_2_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot3:
    # cerco il pilota
    cmpl $3, count
    jnz pilot4
    leal pilot_3_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot4:
    # cerco il pilota
    cmpl $4, count
    jnz pilot5
    leal pilot_4_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot5:
    # cerco il pilota
    cmpl $5, count
    jnz pilot6
    leal pilot_5_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot6:
    # cerco il pilota
    cmpl $6, count
    jnz pilot7
    leal pilot_6_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot7:
    # cerco il pilota
    cmpl $7, count
    jnz pilot8
    leal pilot_7_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot8:
    # cerco il pilota
    cmpl $8, count
    jnz pilot9
    leal pilot_8_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot9:
    # cerco il pilota
    cmpl $9, count
    jnz pilot10
    leal pilot_9_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot10:
    # cerco il pilota
    cmpl $10, count
    jnz pilot11
    leal pilot_10_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo


    pilot11:
    # cerco il pilota
    cmpl $11, count
    jnz pilot12
    leal pilot_11_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot12:
    # cerco il pilota
    cmpl $12, count
    jnz pilot13
    leal pilot_12_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot13:
    # cerco il pilota
    cmpl $13, count
    jnz pilot14
    leal pilot_13_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot14:
    # cerco il pilota
    cmpl $14, count
    jnz pilot15
    leal pilot_14_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot15:
    # cerco il pilota
    cmpl $15, count
    jnz pilot16
    leal pilot_15_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot16:
    # cerco il pilota
    cmpl $16, count
    jnz pilot17
    leal pilot_16_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot17:
    # cerco il pilota
    cmpl $17, count
    jnz pilot18
    leal pilot_17_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot18:
    # cerco il pilota
    cmpl $18, count
    jnz pilot19
    leal pilot_18_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne err_pilota      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo

    pilot19:
    # cerco il pilota
    cmpl $19, count
    jnz invalid_pilot
    leal pilot_19_str, %edx      # confronto il pilota
    cmpb %al, (%edx,%ecx)
    jne invalid_pilot      # se non ho il carattere = passo ad errore pilota

    # se il confronto sta andando bene
    incl %ecx
    jmp leggi_nome  # continuo il ciclo


    invalid_pilot:
    # ################ #
    # STAMPO E TERMINO #
    # ################ #
    # OUTPUT MESSAGGIO ERRORE
    leal invalid_pilot_str, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $7, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    # stampo lo \n
    leal stringa_invio, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    movl $0, flag   # imposto la flag che controlla se c'è un errore
    jmp end_leggiNome


    err_pilota:     # vado qua quando il pilota che sto confrontando non è giusto
    incl count      # passo al confronto con il prossimo pilota
    movl $0, %ecx   # ricomincio a confrontare la stringa dall'inizio
    
    jmp leggi_nome  # continuo il ciclo

fine_lettura:
    movl count, %eax
    movl %eax, id

    # prendo il prossimo carattere per il return
    xorl %eax, %eax
    incl %ecx
    movb (%esi, %ecx), %al  # prendo il carattere che mi servirà una volta fatta la ret

end_leggiNome:
ret


# FUNZIONE CHE CONFRONTA GLI ID E SE SERVE SETTA LE VARIABILI
.type idCompare, @function
idCompare:
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
leal id_str, %eax   # metto l'indirizzo della stringa da convertire in %eax
    call atoi
    cmpl %ecx, id   # confronto l'id convertito con quello del pilota che mi serve
    jne id_NOTuguale

    # se gli id corrispondono
    incl record_pilota
    
    # ###################################################################### #
    # devo convertire gli altri valori e metterli nelle rispettive variabili #
    # ###################################################################### #

    # tempo
    tempo:
        # OUTPUT tempo
        leal temp_str, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
        movl temp_str_len, %edx     # dico quanto dovrà essere lungo il messaggio

        call a2file  # scrivo l'output sul file

    # guardo gli rpm
    rpm:
        # stampo la virgola
        leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
        movl $1, %edx # dico quanto dovrà essere lungo il messaggio

        call a2file  # scrivo l'output sul file

        movl rpm_long, %ecx
        cmpl rpmMax, %ecx   # guardo se questi rpm superano l'rpmMax
        jng no_rpmMax
        movl %ecx, rpmMax

        no_rpmMax:
            cmpl $5000, %ecx
            jg no_rpm_low
            # OUTPUT LOW
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
            movl $3, %edx # dico quanto dovrà essere lungo il messaggio

            call a2file  # scrivo l'output sul file

            jmp temperatura

            no_rpm_low:
                cmpl $10000, %ecx
                jg no_rpm_medium
                # OUTPUT MEDIUM
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                movl $6, %edx # dico quanto dovrà essere lungo il messaggio

                call a2file  # scrivo l'output sul file

                jmp temperatura

                no_rpm_medium:
                    # OUTPUT HIGH
                    leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                    movl $4, %edx # dico quanto dovrà essere lungo il messaggio

                    call a2file  # scrivo l'output sul file    

    temperatura:
        # stampo la virgola
        leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
        movl $1, %edx # dico quanto dovrà essere lungo il messaggio

        call a2file  # scrivo l'output sul file

        movl temperatura_long, %ecx
        cmpl tempMax, %ecx   # guardo se questa temperatura supera la tempMax
        jng no_tempMax
        movl %ecx, tempMax

        no_tempMax:
            cmpl $90, %ecx
            jg no_temp_low
            # OUTPUT LOW
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
            movl $3, %edx # dico quanto dovrà essere lungo il messaggio

            call a2file  # scrivo l'output sul file

            jmp velocità_Max

            no_temp_low:
                cmpl $110, %ecx
                jg no_temp_medium
                # OUTPUT MEDIUM
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                movl $6, %edx # dico quanto dovrà essere lungo il messaggio

                call a2file  # scrivo l'output sul file

                jmp velocità_Max

                no_temp_medium:
                # OUTPUT HIGH
                leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                movl $4, %edx # dico quanto dovrà essere lungo il messaggio

                call a2file  # scrivo l'output sul file    

    velocità_Max:
        # stampo la virgola
        leal stringa_virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
        movl $1, %edx # dico quanto dovrà essere lungo il messaggio

        call a2file  # scrivo l'output sul file

        movl velocità_long, %ecx
        addl %ecx, velocitàMedia    # sommo la velocità alla velocità media
        cmpl velocitàMax, %ecx   # guardo se questa velocità supera la velocitàMax
        jng no_velocitàMax
        movl %ecx, velocitàMax

        no_velocitàMax:
            cmpl $100, %ecx
            jg no_velocitàMax_low
            # OUTPUT LOW
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
            movl $3, %edx # dico quanto dovrà essere lungo il messaggio

            call a2file  # scrivo l'output sul file

            jmp velocità_Media

            no_velocitàMax_low:
                cmpl $250, %ecx
                jg no_velocitàMax_medium
                # OUTPUT MEDIUM
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                movl $6, %edx # dico quanto dovrà essere lungo il messaggio

                call a2file  # scrivo l'output sul file

                jmp velocità_Media

                no_velocitàMax_medium:
                # OUTPUT HIGH
                leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
                movl $4, %edx # dico quanto dovrà essere lungo il messaggio

                call a2file  # scrivo l'output sul file
    
    velocità_Media:  # messa a caso per saltare le altre print di velocitàMax

    # stampo lo \n
    leal stringa_invio, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
    movl $1, %edx # dico quanto dovrà essere lungo il messaggio

    call a2file  # scrivo l'output sul file

    id_NOTuguale:
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret


# ASCII TO INTEGER FUNCTION
.type atoi, @function
atoi:

xorl %ecx, %ecx     # azzero il valore di ecx

# BACKUP registri
pushl %eax
pushl %ebx
pushl %edx
pushl %esi

# faccio la divisione per 10 e prendo il resto, finche non arrivo a 0
# metto tutti i resti in ecx, moltiplicando ogni volta per 10

movl %eax, %esi     # imposto nel registro %esi l'inizio della stringa eax da convertire
movl $0, num1_len   # resetto il valore del contatore dei caratteri

loopConversione:

    # metto temporaneamente il valore di num1_len in ecx
    pushl %ecx
    movl num1_len, %ecx
    movb (%esi,%ecx), %dl      # prendo il carattere nella posizione num1_len e lo metto in edx
    popl %ecx

    test %dl, %dl     # controllo se sto prendendo un carattere NULL
    jz end_conversione

    subb $48, %dl      # tolgo 48 al carattere, per avere il suo corrispondente numero intero
    pushl %edx      # backup %edx, numero da aggiungere
    movl $10, %ebx      # imposto il fattore a 10

    movl %ecx, %eax     # sposto il numero intero in eax, per aggiungergli un altro pezzo
    mull %ebx   # %ebx*%eax = [%edx:%eax]
    popl %edx   # ripristino il resto della divisione in edx
    addb %dl, %al     # aggiungo la cifra convertita
    movl %eax, %ecx     # metto il numero che sto convertendo il ecx

    incl num1_len   # incremento per passare al prossimo carattere

    jmp loopConversione     # continuo il ciclo

end_conversione: 
    # RESTORE registri
    popl %esi
    popl %edx
    popl %ebx
    popl %eax
ret


# INTEGER TO ASCII FUNCTION
.type itoa, @function
itoa:

# faccio la divisione per 10 e prendo il resto, finche non arrivo a 0
# metto tutti i resti in ecx, aggiungendo 48 per farli diventare il loro corrispettivo carattere ascii

leal intToPrint, %esi
movl %ecx, %eax

# conta il numero di caratteri da inserire nella stringa
loopContatore:
    cmpl $0, %eax    # se il risultato della divisione dei 2 numeri è 0
    jz risZero

    xorl %edx, %edx     # resetto il registro che conterrà il resto
    movl $10, %ebx  # imposto il divisore a 10
    divl %ebx   # faccio la divisione per 10, il risualtato sarà in eax
    incl intToPrint_len
    cmpl $0, %eax    # guardo se sono arrivato all'ultimo carattere
    jz end_contatore
    jmp loopContatore

risZero:
    movl $0, %ecx
    movl $1, intToPrint_len

end_contatore:
    movl %ecx, %eax
    pushl intToPrint_len

# prende i numeri in ecx e li converte in caratteri e li inserisce nella stringa risultato
loopConversione_itoa:

    # memorizzo temporaneamente in %eax il valore di risultato_len
    movl intToPrint_len, %ecx
    cmpl $0, %ecx   # controllo se ho ancora caratteri da stampare

    jz end_conversione_itoa

    xorl %edx, %edx     # resetto il registro in modo tale che non interferisca con la divisione

    movl $10, %ebx  # imposto il divisore a 10
    divl %ebx   # [%edx:%eax]/%ebx = %eax	%edx = resto
    addl $48, %edx  # converto il carattere da intero ad ascii

    # memorizzo temporaneamente in %eax il valore di risultato_len
    movl intToPrint_len, %ecx
    decl %ecx   # IMPORTANTE!! decremento la posizione in cui inserire il carattere, perché il contreggio inizia da 0
    
    # USO MOVB PERCHÉ ALTRIMENTI SI PRENDE COSE STRANE
    movb %dl, (%esi,%ecx)   # sposto il carattere estratto nella sua posizione della stringa risultato

    decl intToPrint_len  # decremento il numero di caratteri che devo prendere
    
    jmp loopConversione_itoa

end_conversione_itoa:
    popl intToPrint_len  # ripristino il numero di caratteri che dovrò stampare
ret


# funzione che data una stringa in ecx e la sua lunghezza in edx, la scrive in edi (output file)
.type a2file, @function
a2file:
xorl %eax, %eax
xorl %ebx, %ebx

loopCharToEdi:
    cmpl $0, %edx   # controllo se ho già preso tutti i caratteri
    je end_a2file

    # backup edx (mi serve)
    pushl %edx
    xorl %edx, %edx

    movl contatoreCaratteri, %edx

    movb (%ecx, %eax), %bl

    movb %bl, (%edi, %edx)   # sposto il carattere in %edi

    popl %edx   # restore %edx
    
    incl %eax   # incremento il contatore della stringa che devo convertire
    incl contatoreCaratteri     # incremento il contatore dei caratteri di %edx
    decl %edx   # decremento il contatore della stringa che devo convertire
    jmp loopCharToEdi

end_a2file:
ret
