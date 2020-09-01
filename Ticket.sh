#!/bin/bash
if test -z $1 # prüfen ob Argument für Wartezeit zwischen Anfragen vorhanden ist
then
    SCHLAFEN=10 #Wartezeit auf 10 Sekunden festsetzen, wenn kein Argument vorhanden ist
else
    SCHLAFEN=$1 #Wenn ein Argument vorhanden ist, diesen nutzen
fi
echo "Nutzername eingeben nachname_vorname:" #Aufforderung zur Eingabe des Nutzernamens
read USER #Nutzername von console einlesen

echo -n "Passwort eingeben: "; stty -echo; read PASS; stty echo; echo #Passwort abfragen und in passwd Variable schreiben, ohne das Eingabe angezeigt wird
#read -p -s geht nicht, der Grund ist auch StackOverflow nicht bekannt

while true; do #Schleife ohne exit Bedingung, da kein Abbruch durch Programm selbst gewünscht
    `curl -sk  wlan-login.oszimt.de/logon/cgi/index.cgi > login.html` #Login Seite mit curl abrufen und in Datei sichern -s -> keine Fortschrittsbalken anzeigen
    CODE=`grep -Eo '[0-9a-f]{32}\s[0-9a-f]{32}' login.html` #anmelde-code herausfiltern

    #Anmeldecode besteht aus 2 Hex-Bloecken zu je 32 Zeichen länge und aendert sich bei jedem neuladen der Seite
    if test -z "$CODE" #Abfrage, ob Variable leer ist
    then
        #leer -> angemeldet
        #anzeige des aktuellen verbrauchs
        CURRENT=`grep -Eo -m 1 '[0-9]+\,[0-9]+' login.html` #Herausfiltern der aktuell verbrauchten Daten und anzeige
        if test -z $CURRENT
        then
            echo "Kein Zugriff auf Seite möglich (1)"
            exit 1
        else
            echo "aktuell verbrauchte mb: $CURRENT"
            rm login.html #loeschen der Datei
            sleep $SCHLAFEN
            continue
        fi
    else
        #nicht leer -> muss anmelden
        curl -sdk "uid=$USER&pwd=$PASS&ta_id=$CODE&voucher_logon_btn=TRUE" wlan-login.oszimt.de/logon/cgi/index.cgi#anchor_voucherLogon #Senden der Daten an das Ziel des Formulars
    fi
done #Ende der Schleife
