#!/bin/bash

# Funciones para mensajes
status() { echo -e "\033[1;34m[...]\033[0m $*"; }
ok()     { echo -e "\033[1;32m[✔]\033[0m $*"; }
error()  { echo -e "\033[1;31m[✘]\033[0m $*" >&2; }

# Función para ejecutar comandos ocultando salida, con manejo de error
run() {
  if ! "$@" > /dev/null 2>&1; then
    error "Error ejecutando: $*"
    exit 1
  fi
}

create_symlinks() {
  status "Creando link simbólico de la zshrc"
  user_home="/home/${SUDO_USER:-$USER}"
  if [[ ! -d "$user_home" ]]; then
    error "El directorio $user_home no existe, no se puede crear el link simbólico"
    exit 1
  fi
  run sudo rm -f /root/.zshrc
  run sudo ln -s "$user_home/.zshrc" /root/.zshrc
  ok "Link simbólico de .zshrc creado para root"
}

install_dependencies() {
  status "Instalando dependencias"
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
    libnl-genl-3-dev ninja-build python3
  ok "Dependencias instaladas"
}

clone_and_build_bspwm() {
  status "Clonando y compilando bspwm"
  run rm -rf ~/Downloads/bspwm
  cd ~/Downloads
  run git clone https://github.com/baskerville/bspwm.git
  cd bspwm
  run make
  run sudo make install
  ok "bspwm compilado e instalado"
}

clone_and_build_sxhkd() {
  status "Clonando y compilando sxhkd"
  run rm -rf ~/Downloads/sxhkd
  cd ~/Downloads
  run git clone https://github.com/baskerville/sxhkd.git
  cd sxhkd
  run make
  run sudo make install
  ok "sxhkd compilado e instalado"
}

configure_bspwm_sxhkd() {
  mkdir -p ~/.config/{bspwm,sxhkd}
  cp ~/auto_bspwm/bspwmrc_new ~/.config/bspwm/bspwmrc
  chmod +x ~/.config/bspwm/bspwmrc
  cp ~/auto_bspwm/sxhkdrc_new ~/.config/sxhkd/sxhkdrc
  ok "bspwm y sxhkd configurados"
}

install_kitty() {
  status "Instalando y configurando kitty"
  run sudo apt install -y kitty
  mkdir -p ~/.config/kitty
  cp  ~/auto_bspwm/kitty/kitty.conf ~/.config/kitty/
  cp  ~/auto_bspwm/kitty/color.ini ~/.config/kitty/
  sudo cp -r ~/auto_bspwm/Hack/ /usr/share/fonts/
  ok "kitty instalado y configurado"
}

install_polybar() {
  status "Instalando polybar"
  run rm -rf ~/Downloads/polybar
  cd ~/Downloads
  run git clone --recursive https://github.com/polybar/polybar
  cd polybar
  mkdir -p build
  cd build
  run cmake ..
  run make -j"$(nproc)"
  run sudo make install

  status "Configurando polybar"
  run rm -rf ~/Downloads/blue-sky
  cd ~/Downloads
  run git clone https://github.com/VaughnValle/blue-sky.git
  mkdir -p ~/.config/polybar
  cp -r ~/Downloads/blue-sky/polybar/* ~/.config/polybar/

  # Evitar duplicados en bspwmrc
  if ! grep -Fxq "~/.config/polybar/launch.sh &" ~/.config/bspwm/bspwmrc; then
    echo "~/.config/polybar/launch.sh &" >> ~/.config/bspwm/bspwmrc
  fi

  run sudo cp -r ~/Downloads/blue-sky/polybar/fonts/* /usr/share/fonts/truetype/
  run fc-cache -v
  ok "polybar instalado y configurado"
}

install_picom() {
  status "Instalando picom"
  run rm -rf ~/Downloads/picom
  cd ~/Downloads
  run git clone https://github.com/ibhagwan/picom.git
  cd picom
  run git submodule update --init --recursive
  run meson --buildtype=release . build
  run ninja -C build
  run sudo ninja -C build install

  status "Configurando picom"
  mkdir -p ~/.config/picom
  cp -f ~/auto_bspwm/picom.conf ~/.config/picom/
  ok "picom instalado y configurado"
}

install_powerlevel10k() {
  status "Instalando powerlevel10k para usuario"
  if [[ ! -d ~/.powerlevel10k ]]; then
    run git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
  fi
  if ! grep -qxF 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' ~/.zshrc; then
    echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
  fi

  status "Configurando powerlevel10k para root"
  if [[ ! -d /root/.powerlevel10k ]]; then
    run sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.powerlevel10k
  fi
  run sudo cp ~/auto_bspwm/.p10k-root_new.zsh /root/.p10k.zsh

  # Evitar duplicados en /root/.zshrc
  if ! sudo grep -qxF 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' /root/.zshrc 2>/dev/null; then
    echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' | sudo tee -a /root/.zshrc > /dev/null
  fi
  if ! sudo grep -qxF '[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh' /root/.zshrc 2>/dev/null; then
    echo '[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh' | sudo tee -a /root/.zshrc > /dev/null
  fi

  run sudo chsh -s /bin/zsh root
  ok "powerlevel10k instalado y configurado para usuario y root"
}

install_utilities() {
  status "Instalando herramientas adicionales"
  run sudo apt install -y rofi micro

  mkdir -p ~/.config/polybar ~/.config/bin
  cp -r ~/auto_bspwm/polybar/* ~/.config/polybar/
  cp -r ~/auto_bspwm/bin/* ~/.config/bin/

  # Manejo de archivos .deb con respaldo
  mv -n ~/auto_bspwm/bat_0.25.0_amd64.deb ~/Desktop/ 2>/dev/null || true
  mv -n ~/auto_bspwm/lsd_1.1.5_amd64.deb ~/Desktop/ 2>/dev/null || true

  cd ~/Desktop || exit 1
  if sudo dpkg -i bat_0.25.0_amd64.deb lsd_1.1.5_amd64.deb > /dev/null 2>&1; then
    ok "Paquetes bat y lsd instalados"
  else
    error "Error instalando paquetes .deb desde Desktop"
  fi

  # Respaldo de archivos zshrc existentes
  if [[ -f ~/.zshrc ]]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%s)
    status "Respaldo de ~/.zshrc creado"
  fi

  cp -f ~/auto_bspwm/zsh/.zshrc ~/.zshrc
  run sudo cp ~/auto_bspwm/zsh/.zshrc /root/.zshrc

  rm -f ~/Desktop/bat_0.25.0_amd64.deb ~/Desktop/lsd_1.1.5_amd64.deb
  ok "Herramientas adicionales instaladas y configuradas"
}

finalize_setup() {
  status "Eliminando archivos innecesarios de la zsh"
  run sudo rm -rf /usr/local/share/zsh/site-functions/_bspc
  ok "Limpieza finalizada"
}

# Aquí podrías llamar a las funciones en orden:
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
