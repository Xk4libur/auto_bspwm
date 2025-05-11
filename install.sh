#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m

echo -e "${greenColour}bspwm installer 4 kali${endColour} - ${yellowColour}Made by xk4libur${endColour}"

read -sp "[?] Ingresa tu contraseña de sudo: " password
echo -e "\n"

# Habilitar sudo sin contraseña por 15 minutos (requiere contraseña inicial)
echo "$password" | sudo -S bash -c "echo '$USER ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/temp_nopasswd" 2>/dev/null
trap 'sudo rm -f /etc/sudoers.d/temp_nopasswd' EXIT  # Eliminar al finalizar

# Instalar dependencias
sudo apt update && sudo apt install -y \
  build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev \
  libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev \
  libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev

# Clonar repositorios
cd
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git
cd bspwm
make
sudo make install
cd ../sxhkd
make
sudo make install
sudo apt install bspwm -y 

# Crear directorios de configuración
mkdir -p ~/.config/{bspwm,sxhkd}
cd ~/.bspwm/examples   
cp bspwmrc ~/.config/bspwm/
cp sxhkdrc ~/.config/sxhkd/
chmod +x ~/.config/bspwm/bspwmrc 

# Sustituir el archivo de configuración de sxhkd
cp -f ~/auto_bspwm/sxhdrc_new ~/.config/sxhkd/sxhkdrc