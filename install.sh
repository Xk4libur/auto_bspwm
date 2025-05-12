#!/bin/bash

# Colores
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

echo -e "\n${greenColour}bspwm installer for Kali Linux${endColour} - ${yellowColour}Made by xk4libur${endColour}\n"

# Función para manejar errores
handle_error() {
    echo -e "${redColour}[ERROR]${endColour} Algo salió mal en el paso anterior"
    exit 1
}

# Instalar dependencias
echo -e "${blueColour}[+] Instalando dependencias...${endColour}"
sudo apt update && sudo apt install -y \
    build-essential git vim cmake cmake-data pkg-config meson \
    python3-sphinx python3-xcbgen xcb-proto \
    libxcb1-dev libxcb-util0-dev libxcb-ewmh-dev \
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev \
    libxcb-xinerama0-dev libxcb-xtest0-dev libxcb-shape0-dev \
    libxcb-xrm-dev libxcb-damage0-dev libxcb-xfixes0-dev \
    libxcb-render0-dev libxcb-render-util0-dev libxcb-composite0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-xkb-dev \
    libxcb-cursor-dev libx11-xcb-dev libxcb-glx0-dev \
    libpixman-1-dev libdbus-1-dev libconfig-dev \
    libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev \
    libev-dev libcairo2-dev libasound2-dev libpulse-dev \
    libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
    libnl-genl-3-dev || handle_error

# Clonar y compilar bspwm
echo -e "${blueColour}[+] Clonando y compilando bspwm...${endColour}"
cd ~ || handle_error
git clone https://github.com/baskerville/bspwm.git || handle_error
cd bspwm || handle_error
make || handle_error
sudo make install || handle_error

# Clonar y compilar sxhkd
echo -e "${blueColour}[+] Clonando y compilando sxhkd...${endColour}"
cd ~ || handle_error
git clone https://github.com/baskerville/sxhkd.git || handle_error
cd sxhkd || handle_error
make || handle_error
sudo make install || handle_error

# Instalar bspwm desde repositorios (para asegurar dependencias)
echo -e "${blueColour}[+] Instalando bspwm desde repositorios...${endColour}"
sudo apt install -y bspwm || handle_error

# Configuración de bspwm y sxhkd
echo -e "${blueColour}[+] Configurando bspwm y sxhkd...${endColour}"
mkdir -p ~/.config/{bspwm,sxhkd} || handle_error

# Copiar archivos de configuración de ejemplo
if [ -d "/usr/share/doc/bspwm/examples/" ]; then
    sudo cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/ || handle_error
    sudo cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/ || handle_error
    sudo chmod +x ~/.config/bspwm/bspwmrc || handle_error
else
    echo -e "${yellowColour}[!] No se encontraron los archivos de ejemplo en /usr/share/doc/bspwm/examples/${endColour}"
fi

# Copiar configuraciones personalizadas si existen
if [ -d ~/auto_bspwm ]; then
    echo -e "${blueColour}[+] Copiando configuraciones personalizadas...${endColour}"
    
    # sxhkd
    if [ -f ~/auto_bspwm/sxhkdrc_new ]; then
        cp -f ~/auto_bspwm/sxhkdrc_new ~/.config/sxhkd/sxhkdrc || handle_error
    fi
    
    # kitty
    sudo apt install -y kitty || handle_error
    mkdir -p ~/.config/kitty || handle_error
    if [ -f ~/auto_bspwm/kitty.conf ]; then
        cp -f ~/auto_bspwm/kitty.conf ~/.config/kitty/ || handle_error
    fi
    if [ -f ~/auto_bspwm/color.ini ]; then
        cp -f ~/auto_bspwm/color.ini ~/.config/kitty/ || handle_error
    fi
    
    # Fuentes Hack Nerd
    if [ -d ~/auto_bspwm/Hack ]; then
        sudo cp -r ~/auto_bspwm/Hack/ /usr/share/fonts/ || handle_error
        sudo fc-cache -fv || handle_error
    fi
else
    echo -e "${yellowColour}[!] No se encontró el directorio auto_bspwm con configuraciones personalizadas${endColour}"
fi

# Instalar polybar
echo -e "${blueColour}[+] Instalando polybar...${endColour}"
cd ~ || handle_error
git clone --recursive https://github.com/polybar/polybar || handle_error
cd polybar || handle_error
mkdir build || handle_error
cd build || handle_error
cmake .. || handle_error
make -j$(nproc) || handle_error
sudo make install || handle_error

# Configurar polybar
echo -e "${blueColour}[+] Configurando polybar...${endColour}"
cd ~ || handle_error
git clone https://github.com/VaughnValle/blue-sky.git || handle_error
mkdir ~/.config/polybar || handle_error
cd ~/Downloads/blue-sky/polybar/ || handle_error
sudo cp * -r ~/.config/polybar || handle_error
echo '~/.config/polybar/launch.sh &' >> ~/.config/bspwm/bspwmrc || handle_error
cd fonts || handle_error
sudo cp * /usr/share/fonts/truetype/ || handle_error
fc-cache -v || handle_error

# Instalar picom
echo -e "${blueColour}[+] Instalando picom...${endColour}"
git clone https://github.com/ibhagwan/picom.git || handle_error
cd picom/ || handle_error
git submodule update --init --recursive || handle_error
meson --buildtype=release . build || handle_error
ninja -C build || handle_error
sudo ninja -C build install || handle_error

# Configurar picom
echo -e "${blueColour}[+] Configurando picom...${endColour}"
mkdir -p ~/.config/picom || handle_error
cd ~/.config/picom || handle_error
  if [ -f ~/auto_bspwm/picom.conf ]; then
        cp -f ~/auto_bspwm/picom.conf ~/.config/picom|| handle_error
  fi

# Instalar rofi
echo -e "${blueColour}[+] Instalando rofi...${endColour}"
sudo apt install -y rofi || handle_error

echo -e "\n${greenColour}[+] Instalación completada con éxito!${endColour}"
echo -e "${blueColour}[*] Para iniciar bspwm, cierra sesión y seleccionalo en el gestor de ventanas${endColour}"