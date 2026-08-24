#!/bin/sh
# Fuerza unmute + 100% volume del microfono del PRO X 2 LIGHTSPEED
# El dongle reporta "broken mixer GET_CUR" y el kernel no puede leer
# el estado del mute, dejandolo muteado por defecto.
# Usamos el card ID "LIGHTSPEED" en lugar del numero (que cambia).
logger "prox2-mic-unmute: iniciando, esperando ALSA..."
sleep 5
amixer -c LIGHTSPEED sset "Mic" 100% unmute >/dev/null 2>&1
logger "prox2-mic-unmute: amixer ejecutado, exit=$?"
