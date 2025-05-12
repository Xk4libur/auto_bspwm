#!/bin/bash

# Colores
greenColour="\033[0;32m\033[1m"
endColour="\033[0m\033[0m"
redColour="\033[0;31m\033[1m"
blueColour="\033[0;34m\033[1m"
yellowColour="\033[0;33m\033[1m"
purpleColour="\033[0;35m\033[1m"
turquoiseColour="\033[0;36m\033[1m"
grayColour="\033[0;37m\033[1m"

echo -e "\n${greenColour}bspwm installer for Kali Linux${endColour} - ${yellowColour}Made by xk4libur${endColour}\n"

# Verificar si el sistema operativo es Kali Linux
if ! grep -qi "kali" /etc/os-release; then
    echo -e "${yellowColour}[!] Este script está diseñado para Kali Linux${endColour}"
    exit 1
fi

# Instalar dependencias
echo -e "${blueColour}[+] Instalando dependencias...${endColour}"
sudo apt update
sudo apt install -y build-essential git vim cmake cmake-data pkg-config meson \
    python3-sphinx python3-xcbgen xcb-proto \
    libxcb1-dev libxcb-util0-dev libxcb-ewmh-dev \
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev \
    libxcb-xinerama0-dev libxcb-xtest0-dev libxcb-shape0-dev \
    libxcb-xrm-dev libxcb-damage0-dev libxcb-xfixes0-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-composite0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-xkb-dev \
    libxcb-cursor-dev libx11-xcb-dev libpcre3-dev libpcre2-dev libxcb-glx0-dev \
    libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libevdev-dev uthash-dev \
    libev-dev libcairo2-dev libasound2-dev libpulse-dev \
    libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
    libnl-genl-3-dev

# Clonar y compilar bspwm
echo -e "${blueColour}[+] Clonando y compilando bspwm...${endColour}"
cd ~/Downloads
git clone https://github.com/baskerville/bspwm.git
cd bspwm/
make
sudo make install
sudo apt install -y bspwm

# Clonar y compilar sxhkd
echo -e "${blueColour}[+] Clonando y compilando sxhkd...${endColour}"
cd ~/Downloads
git clone https://github.com/baskerville/sxhkd.git
cd sxhkd/
make
sudo make install

# Configuración de bspwm y sxhkd
echo -e "${blueColour}[+] Configurando bspwm y sxhkd...${endColour}"
mkdir -p ~/.config/{bspwm,sxhkd}

# Copiar configuraciones personalizadas si existen
echo -e "${blueColour}[+] Copiando configuraciones personalizadas...${endColour}"

# bspwm
cp -f ~/auto_bspwm/bspwmrc_new ~/.config/bspwm/bspwmrc
chmod +x ~/.config/bspwm/bspwmrc

# sxhkd
cp -f ~/auto_bspwm/sxhkdrc_new ~/.config/sxhkd/sxhkdrc

# kitty
sudo apt install -y kitty
mkdir -p ~/.config/kitty
sudo mv ~/auto_bspwm/kitty.conf ~/.config/kitty/
sudo mv ~/auto_bspwm/color.ini ~/.config/kitty/
sudo cp -r ~/auto_bspwm/Hack/ /usr/share/fonts/


# Instalar polybar
echo -e "${blueColour}[+] Instalando polybar...${endColour}"
cd ~/Downloads
git clone --recursive https://github.com/polybar/polybar
cd polybar/
mkdir build && cd build
cmake ..
make -j$(nproc)
sudo make install

# Configurar polybar
echo -e "${blueColour}[+] Configurando polybar...${endColour}"
cd ~/Downloads
git clone https://github.com/VaughnValle/blue-sky.git
mkdir -p ~/.config/polybar
cd ~/Downloads/blue-sky/polybar/
cp -r * ~/.config/polybar/
echo "~/.config/polybar/launch.sh &" >> ~/.config/bspwm/bspwmrc
cd fonts/
sudo cp * /usr/share/fonts/truetype/
fc-cache -v


# Instalar picom
echo -e "${blueColour}[+] Instalando picom...${endColour}"
cd ~/Downloads
git clone https://github.com/ibhagwan/picom.git
cd picom/
git submodule update --init --recursive
meson --buildtype=release . build
ninja -C build
sudo ninja -C build install

# Configurar picom
echo -e "${blueColour}[+] Configurando picom...${endColour}"
mkdir -p ~/.config/picom
cp -f ~/auto_bspwm/picom.conf ~/.config/picom

# Instalar rofi
echo -e "${blueColour}[+] Instalando rofi...${endColour}"
sudo apt install -y rofi

# Meter los nuevos archivos de la polybar
cp -r ~/auto_bspwm/polybar/ ~/.config/polybar/

# Meter los nuevos archivos binarios
mkdir -p ~/.config/bin
cp -r ~/auto_bspwm/bin/* ~/.config/bin/

# Limpiar archivos temporales
echo -e "${blueColour}[+] Limpiando archivos temporales...${endColour}"
rm -rf ~/bspwm ~/sxhkd ~/polybar ~/picom ~/blue-sky

echo -e "\n${greenColour}[+] Instalación completada con éxito!${endColour}"
echo -e "${blueColour}[*] Para iniciar bspwm, cierra sesión y seleccionalo en el gestor de ventanas${endColour}"
