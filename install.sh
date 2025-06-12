#!/bin/bash

# Colores
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"
end="\033[0m"

# Funciones de status
status() {
  echo -e "${blue}[•] $1...${end}"
}

ok() {
  echo -e "${green}[✔] $1${end}"
}

run() {
  "$@" > /dev/null 2>&1
}

print_title() {
  echo -e "\n${green}bspwm installer for Kali Linux${end} - ${yellow}Made by xk4libur${end}\n"
}

create_symlinks() {
  status "Creando link simbólico de la zshrc"
  run sudo rm -f /root/.zshrc
  run sudo ln -s /home/$USER/.zshrc /root/.zshrc
  ok "Link creado"
}

install_dependencies() {
  status "Instalando dependencias"
  run sudo apt update
  run sudo apt install -y build-essential git vim cmake cmake-data pkg-config meson \
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
    libnl-genl-3-dev ninja-build python3
  ok "Dependencias instaladas"
}

clone_and_build_bspwm() {
  status "Clonando y compilando bspwm"
  run cd ~/Downloads
  run git clone https://github.com/baskerville/bspwm.git
  run cd bspwm
  run make && run sudo make install
  run sudo apt install -y bspwm
  ok "bspwm instalado"
}

clone_and_build_sxhkd() {
  status "Clonando y compilando sxhkd"
  run cd ~/Downloads
  run git clone https://github.com/baskerville/sxhkd.git
  run cd sxhkd
  run make && run sudo make install
  ok "sxhkd instalado"
}

configure_bspwm_sxhkd() {
  status "Configurando bspwm y sxhkd"
  run mkdir -p ~/.config/{bspwm,sxhkd}

  script_dir="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd)"
  bspwmrc_path="$script_dir/bspwmrc_new"
  sxhkdrc_path="$script_dir/sxhkdrc_new"

  if [ -f "$bspwmrc_path" ]; then
    run cp -f "$bspwmrc_path" ~/.config/bspwm/bspwmrc
    run chmod +x ~/.config/bspwm/bspwmrc
  else
    echo -e "${yellow}[!] bspwmrc_new no encontrado, se omitió la copia${end}"
  fi

  if [ -f "$sxhkdrc_path" ]; then
    run cp -f "$sxhkdrc_path" ~/.config/sxhkd/sxhkdrc
  else
    echo -e "${yellow}[!] sxhkdrc_new no encontrado, se omitió la copia${end}"
  fi

  ok "bspwm y sxhkd configurados"
}

install_kitty() {
  status "Instalando y configurando kitty"
  run sudo apt install -y kitty
  run mkdir -p ~/.config/kitty
  run sudo mv ~/auto_bspwm/kitty/kitty.conf ~/.config/kitty/
  run sudo mv ~/auto_bspwm/kitty/color.ini ~/.config/kitty/
  run sudo cp -r ~/auto_bspwm/Hack/ /usr/share/fonts/
  ok "kitty instalado y configurado"
}

install_polybar() {
  status "Instalando polybar"
  run cd ~/Downloads
  run git clone --recursive https://github.com/polybar/polybar
  run cd polybar
  run mkdir build
  run cd build
  run cmake .. && run make -j$(nproc) && run sudo make install

  status "Configurando polybar"
  run cd ~/Downloads
  run git clone https://github.com/VaughnValle/blue-sky.git
  run mkdir -p ~/.config/polybar
  run cp -r ~/Downloads/blue-sky/polybar/* ~/.config/polybar/
  run echo "~/.config/polybar/launch.sh &" >> ~/.config/bspwm/bspwmrc
  run sudo cp ~/Downloads/blue-sky/polybar/fonts/* /usr/share/fonts/truetype/
  run fc-cache -v
  ok "polybar instalado y configurado"
}

install_picom() {
  status "Instalando picom"
  run cd ~/Downloads
  run git clone https://github.com/ibhagwan/picom.git
  run cd picom
  run git submodule update --init --recursive
  run meson --buildtype=release . build
  run ninja -C build
  run sudo ninja -C build install

  status "Configurando picom"
  run mkdir -p ~/.config/picom
  run sudo mv ~/auto_bspwm/picom.conf ~/.config/picom/
  ok "picom instalado y configurado"
}

install_powerlevel10k() {
  status "Instalando powerlevel10k"
  run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
  echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc

  status "Configurando powerlevel10k para root"
  run sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
  run sudo mv ~/auto_bspwm/.p10k-root_new.zsh /root/.p10k.zsh
  echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' | sudo tee -a /root/.zshrc > /dev/null
  echo '[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh' | sudo tee -a /root/.zshrc > /dev/null
  run sudo chsh -s /bin/zsh root
  ok "powerlevel10k instalado y configurado"
}

install_utilities() {
  status "Instalando herramientas adicionales"
  run sudo apt install -y rofi micro
  run sudo mv ~/auto_bspwm/polybar/* ~/.config/polybar/
  run mkdir -p ~/.config/bin
  run sudo mv ~/auto_bspwm/bin/* ~/.config/bin/
  run sudo mv ~/auto_bspwm/bat_0.25.0_amd64.deb ~/Desktop/
  run sudo mv ~/auto_bspwm/lsd_1.1.5_amd64.deb ~/Desktop/
  run cd ~/Desktop
  run sudo dpkg -i bat_0.25.0_amd64.deb lsd_1.1.5_amd64.deb
  run sudo mv ~/auto_bspwm/zsh/.zshrc ~/.zshrc
  run sudo mv ~/auto_bspwm/zsh/.zshrc /root/.zshrc
  run sudo rm ~/Desktop/bat_0.25.0_amd64.deb ~/Desktop/lsd_1.1.5_amd64.deb
  ok "Herramientas adicionales instaladas"
}

finalize_setup() {
  status "Eliminando archivos innecesarios de la zsh"
  run sudo rm -rf /usr/local/share/zsh/site-functions/_bspc
  ok "Limpieza finalizada"
}

# Ejecución secuencial
print_title
create_symlinks
install_dependencies
clone_and_build_bspwm
clone_and_build_sxhkd
configure_bspwm_sxhkd
install_kitty
install_polybar
install_picom
install_powerlevel10k
install_utilities
finalize_setup

echo -e "\n${green}[✔] BSPWM instalado y configurado correctamente!${end}"
