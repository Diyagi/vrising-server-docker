#!/bin/bash

# First we get the hexdec value of the Win PID 
WinHexPID=$(winedbg --command "info proc" | grep -Po '^\s*\K.{8}(?=.*VRisingServer\.exe)')

# Now we convert the hexdec to decimal 
# and use it to send an taskkill via CMD
wine cmd.exe /C "taskkill /pid $(( 0x$WinHexPID ))"

# Wineserver should exit after the gameserver is shutdown,
# so we wait for it
wineserver -w

exit
# Yeepii, we gracefully shutdown the gameserver! \'-'/