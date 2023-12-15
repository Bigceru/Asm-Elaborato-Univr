# Elaborato ASM - Laboratorio Architettura degli Elaboratori
## Descrizione del progetto
Si scriva un programma in assembly che restituisca i dati relativi al solo pilota indicato nella
prima riga del file, in base a delle soglie indicate.
Vengono definite tre soglie per tutti i dati monitorati: LOW,MEDIUM,HIGH.
Il file di output dovrà riportare queste soglie per tutti gli istanti di tempo in cui il pilota è
monitorato.
Le righe del file di output saranno strutturate nel seguente modo e ordine: \<tempo\>,\<livello\>,
\<rpm\>,\<livello temperatura\>,\<livello velocità\>
Inoltre, viene richiesto di aggiungere alla fine del file di output una riga aggiuntiva che
contenga, nel seguente ordine: il numero di giri massimi rilevati, la temperatura massima
rilevata, la velocità di picco e infine la velocità media.
La struttura dell’ultima riga sarà quindi la seguente:
\<rpm max\>,\<temp max\>,\<velocità max\>,\<velocità media\>
Le soglie per i dati monitorati sono così definite:
+ Giri Motore
	* LOW: rpm <= 5000
	* MEDIUM: 5000 < rpm <=10000
	* HIGH: rpm > 10000
+ Temperatura
	* LOW: temp <= 90
	* MEDIUM: 90 < temp <= 110
	* HIGH: temp > 110
+ Velocità
	* LOW: speed <= 100
	* MEDIUM: 100< speed <=250
	* HIGH: speed > 250
	
## Documentazione
Per tutta la documentazione visionare il file Relazione.pdf