#!/bin/bash

Directorio="playbook_correo"
archivo="$Directorio/intalacion.yml"
configuracion="$Directorio/configuracion"
principal="$configuracion/principal.cf.j2"
inventario="$Directorio/inventory.ini"

if mkdir -p "$TEMPLATE_DIR"; then
    echo "Directorio '$Directorio' creado correctamente."
else
    echo "Error: No se pudo crear el directorio '$Director>
    exit 1
fi

