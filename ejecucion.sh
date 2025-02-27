#!/bin/bash

SCRIPT1="./script.sh"
SCRIPT2="./script_docker.sh"
SCRIPT3="./menu.sh"

while true; do
    echo "==== Menú Principal ===="
    echo "1) Ejecutar el primer script"
    echo "2) Ejecutar el segundo script"
    echo "3) Ejecutar el tercer script"
    echo "4) Salir"
    read -p "Seleccione una opción: " opcion

    if [ "$opcion" = "1" ]; then
        if [ -f "$SCRIPT1" ]; then
            bash "$SCRIPT1"
        else
            echo "Error: El script 1 no se encontró en $SCRIPT1"
        fi
    elif [ "$opcion" = "2" ]; then
        if [ -f "$SCRIPT2" ]; then
            bash "$SCRIPT2"
        else
            echo "Error: El script 2 no se encontró en $SCRIPT2"
        fi
    elif [ "$opcion" = "3" ]; then
        if [ -f "$SCRIPT3" ]; then
            bash "$SCRIPT3"
        else
            echo "Error: El script 3 no se encontró en $SCRIPT3"
        fi
    elif [ "$opcion" = "4" ]; then
        echo "Saliendo..."
        exit 0
    else
        echo "Opción no válida. Intente nuevamente."
    fi

done
