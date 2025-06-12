#!/bin/bash

# === Colores ===
green="\e[1;32m"
red="\e[1;31m"
blue="\e[1;34m"
yellow="\e[1;33m"
reset="\e[0m"

info() { echo -e "${blue}[+]${reset} $1"; }
success() { echo -e "${green}[✔]${reset} $1"; }
error() { echo -e "${red}[✘]${reset} $1"; }


# === Inicio ===
echo -e "\n${green}bspwm installer for Kali Linux${reset} - ${yellow}Made by xk4libur${reset}\n"

# === Funciones ===

crear_symlink_zshrc() {
    info "Creando link simbólico de la zshrc..."
    sudo rm -f /root/.zshrc
    sudo ln -s /home/$USER/.zshrc /root/.zshrc
}

instalar_dependencias() {
    info "Instalando dependencias..." 
    sudo apt update &>/dev/null
    sudo apt install -y build-essential git vim cmake cmake-data pkg-config meson \
        python3-sphinx python3-xcbgen xcb-proto \
        libxcb{1,-util0,-ewmh,-randr0,-icccm4,-keysyms1,-xinerama0,-xtest0,-shape0,-xrm,-damage0,-xfixes0,-render0,-render-util0,-composite0,-image0,-present,-xkb,-cursor}-dev \
        libx11-xcb-dev libpcre{3,2}-dev libxcb-glx0-dev \
        libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev \
        libevdev-dev uthash-dev libev-dev libcairo2-dev \
        libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev \
        libcurl4-openssl-dev libnl-genl-3-dev kitty rofi micro &>/dev/null
}

compilar_proyecto() {
    local repo=$1 dir=$2
    cd ~/Downloads || exit
    git clone "$repo" "$dir" &>/dev/null
    cd "$dir" || exit
    make &>/dev/null
    sudo make install &>/dev/null
}

instalar_bspwm_sxhkd() {
    info "Instalando bspwm..."
    compilar_proyecto https://github.com/baskerville/bspwm.git bspwm
    sudo apt install -y bspwm &>/dev/null

    info "Instalando sxhkd..."
    compilar_proyecto https://github.com/baskerville/sxhkd.git sxhkd
}

configurar_bspwm_sxhkd() {
    info "Configurando bspwm y sxhkd..."
    mkdir -p ~/.config/{bspwm,sxhkd}
    cp -f ~/auto_bspwm/bspwmrc_new ~/.config/bspwm/bspwmrc && chmod +x ~/.config/bspwm/bspwmrc
    cp -f ~/auto_bspwm/sxhkdrc_new ~/.config/sxhkd/sxhkdrc
}

instalar_kitty() {
    info "Configurando kitty..."
    mkdir -p ~/.config/kitty
    sudo mv ~/auto_bspwm/kitty/*.conf ~/.config/kitty/
    sudo cp -r ~/auto_bspwm/Hack/ /usr/share/fonts/
}

instalar_polybar() {
    info "Instalando polybar..."
    cd ~/Downloads || exit
    git clone --recursive https://github.com/polybar/polybar &>/dev/null
    cd polybar || exit
    mkdir build && cd build
    cmake .. &>/dev/null && make -j"$(nproc)" &>/dev/null
    sudo make install &>/dev/null

    info "Configurando polybar..."
    cd ~/Downloads || exit
    git clone https://github.com/VaughnValle/blue-sky.git &>/dev/null
    mkdir -p ~/.config/polybar
    cp -r ~/Downloads/blue-sky/polybar/fonts/* ~/.config/polybar/
    echo "~/.config/polybar/launch.sh &" >> ~/.config/bspwm/bspwmrc
    sudo cp ~/Downloads/blue-sky/fonts/* /usr/share/fonts/truetype/
    fc-cache -f &>/dev/null
}

instalar_picom() {
    info "Instalando picom..."
    cd ~/Downloads || exit
    git clone https://github.com/ibhagwan/picom.git &>/dev/null
    cd picom || exit
    git submodule update --init --recursive &>/dev/null
    meson --buildtype=release . build &>/dev/null
    ninja -C build &>/dev/null
    sudo ninja -C build install &>/dev/null

    info "Configurando picom..."
    mkdir -p ~/.config/picom
    sudo mv ~/auto_bspwm/picom.conf ~/.config/picom/
}

instalar_p10k() {
    info "Instalando Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k &>/dev/null
    echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

    sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k &>/dev/null
    sudo mv ~/auto_bspwm/.p10k-root_new.zsh /root/.p10k.zsh
}

configurar_binarios_y_temas() {
    info "Instalando binarios, rofi y micro..."
    mkdir -p ~/.config/bin ~/.config/polybar

    # No uses sudo para mover a tu home
    mv ~/auto_bspwm/polybar/* ~/.config/polybar/
    mv ~/auto_bspwm/bin/* ~/.config/bin/
    mv ~/auto_bspwm/zsh/.zshrc ~/.zshrc

    info "Instalando bat y lsd..."
    mv ~/auto_bspwm/*.deb ~/Desktop/
    sudo dpkg -i ~/Desktop/*.deb &>/dev/null
    rm ~/Desktop/*.deb
}

limpiar_archivos_zsh() {
    info "Eliminando archivos innecesarios de zsh..."
    sudo rm -rf /usr/local/share/zsh/site-functions/_bspc
}

# === Ejecución de funciones ===
crear_symlink_zshrc
instalar_dependencias
instalar_bspwm_sxhkd
configurar_bspwm_sxhkd
instalar_kitty
instalar_polybar
instalar_picom
instalar_p10k
configurar_binarios_y_temas
limpiar_archivos_zsh

# Tema rofi (último porque requiere interacción)
rofi-theme-selector
success "Instalación y configuración completadas correctamente."