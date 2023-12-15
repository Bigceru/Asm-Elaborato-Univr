#setto delle variabili
AS_FLAGS = --32

all: bin/telemetry	#regola "universale", dopo basta che io scriva make

obj/assembly.o:
	# gcc -m32 src/telemetry.s -o obj/telemetry.o
	as $(AS_FLAGS) src/telemetry.s -o obj/telemetry.o		#--32 -gstabs

obj/telemetry.o: obj/assembly.o
	gcc -m32 -c src/main.c -o obj/main.o

bin/telemetry: obj/telemetry.o
	gcc -m32 -static obj/telemetry.o obj/main.o -o bin/telemetry

clean:	#etichetta "universale", per cancellare i file che creo
	rm -rf obj/* bin/*