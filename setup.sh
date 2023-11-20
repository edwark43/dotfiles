#!/usr/bin/env bash

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.ricebackup
date=$(date +%Y%m%d-%H%M%S)

logo () {
	
	local text="${1:?}"
	echo -en " ____________
< Arch Linux >
 ------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\*
                ||----w |
                ||     ||
      edwark43 dotfiles\n\n"
    printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

########## ---------- Welcome ---------- ##########

logo "Welcome!"
printf '%s%sThis script will check if you have the necessary dependencies, and if not, it will install them. Then, it will clone the RICE to your HOME directory.\nAfter that, it will create a local backup of your files, and then copy my dotfiles to your computer.\n\nMy dotfiles DO NOT modify any of your system configurations.\nYou will be prompted for your root password to install any missing dependencies and/or to switch to the zsh shell if it is not your default.\n\nThis script does not have the potential to break your system, it only copies files from my repository to your HOME directory.%s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
	read -rp " Do you wish to continue? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) printf " Error: just write 'y' or 'n'\n\n";;
		esac
    done
clear

########## ---------- Install packages ---------- ##########

logo "Installing needed packages.."

dependencies=(alacritty base-devel brightnessctl bspwm dunst feh git jgmenu \
              jq libnotify libwebp lsd maim mpc mpd ncmpcpp neofetch neovim \
              pacman-contrib pamixer papirus-icon-theme physlock picom playerctl \
	      polkit-gnome polybar ranger rofi rustup sxhkd \
	      ttf-inconsolata ttf-jetbrains-mono ttf-jetbrains-mono-nerd ttf-joypixels \
              ttf-terminus-nerd ueberzug webp-pixbuf-loader xclip xdg-user-dirs xdo xdotool \
	      xorg-xkill xorg-xprop xorg-xrandr xorg-xsetroot xorg-xwininfo \
       	      zsh zsh-autosuggestions zsh-history-substring-search zsh-syntax-highlighting)

is_installed() {
  pacman -Qi "$1" &> /dev/null
  return $?
}

printf "%s%sChecking for required packages...%s\n" "${BLD}" "${CBL}" "${CNC}"
for package in "${dependencies[@]}"
do
  if ! is_installed "$package"; then
    sudo pacman -S "$package" --noconfirm
    printf "\n"
  else
    printf '%s%s is already installed on your system!%s\n' "${CGR}" "$package" "${CNC}"
    sleep 1
  fi
done
sleep 3
clear

########## ---------- Preparing Folders ---------- ##########

# Checks if the file user-dirs.dirs does not exist in ~/.config
	if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
		xdg-user-dirs-update
		echo "Creating xdg-user-dirs"
	fi
sleep 2 
clear

########## ---------- Cloning the Rice! ---------- ##########

logo "Downloading dotfiles"

repo_url="https://github.com/edwark43/dotfiles"
repo_dir="$HOME/dotfiles"

# Checks if the repository folder exists, and deletes it if it does.
	if [ -d "$repo_dir" ]; then
		printf "Removing existing dotfiles repository\n"
		rm -rf "$repo_dir"
	fi

# Cloning the repository
printf "Cloning dotfiles from %s\n" "$repo_url"
git clone --depth=1 "$repo_url" "$repo_dir"

sleep 2
clear

########## ---------- Backup files ---------- ##########

logo "Backup files"
printf "Backup files will be stored in %s%s%s/.ricebackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 10

if [ ! -d "$backup_folder" ]; then
  mkdir -p "$backup_folder"
fi

for folder in alacritty bspwm dunst jgmenu mpd ncmpcpp nvim picom polybar ranger rofi sxhkd zsh; do
  if [ -d "$HOME/.config/$folder" ]; then
    mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date"
    echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
  else
    echo "The folder $folder does not exist in $HOME/.config/"
  fi
done

[ -f ~/.zshrc ] && mv ~/.zshrc ~/.ricebackup/.zshrc-backup-"$(date +%Y.%m.%d-%H.%M.%S)"

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 5
clear

########## ---------- Copy the Rice! ---------- ##########

logo "Installing dotfiles.."
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
[ ! -d ~/.local/share/fonts ] && mkdir -p ~/.local/share/fonts
[ ! -d ~/.local/share/asciiart ] && mkdir -p ~/.local/share/asciiart
[ ! -d ~/.local/share/assets ] && mkdir -p ~/.local/share/assets

for files in ~/dotfiles/config/*; do
  cp -R "${files}" ~/.config/
  if [ $? -eq 0 ]; then
	printf "%s%s%s folder copied successfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

for files in ~/dotfiles/misc/bin/*; do
  cp -R "${files}" ~/.local/bin/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied successfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy them manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

for files in ~/dotfiles/misc/fonts/*; do
  cp -R "${files}" ~/.local/share/fonts/
  if [ $? -eq 0 ]; then
	printf "%s%s%s copied succesfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

for files in ~/dotfiles/misc/asciiart/*; do
  cp -R "${files}" ~/.local/share/asciiart/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied successfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

for files in ~/dotfiles/misc/assets/*; do
  cp -R "${files}" ~/.local/share/assets/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied successfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

for files in ~/dotfiles/home/pics/*; do
  cp -R "${files}" ~/pics/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied successfully!%s\n" "${BLD}" "${CGR}" "${files}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${files}" "${CNC}"
	sleep 1
  fi
done

cp -f "$HOME"/dotfiles/home/.zshrc "$HOME"
fc-cache -rv >/dev/null 2>&1
printf "%s%sFile copied succesfully!!%s\n" "${BLD}" "${CGR}" "${CNC}"

sleep 3
clear

########## ---------- Installing Yay & other aur packages ---------- ##########

logo "Installing Yay, Tdrop, xqp, and Brave."
sleep 2
clear

# Installing yay
logo "Installing Yay"
	if command -v yay >/dev/null 2>&1; then
		printf "%s%sYay is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sInstalling yay%s\n" "${BLD}" "${CBL}" "${CNC}"
		{
			cd "$HOME" || exit
			git clone https://aur.archlinux.org/yay.git
			cd yay || exit
			makepkg -si --noconfirm
		} || {
		printf "\n%s%sFailed to install Yay.%s\n" "${BLD}" "${CRE}" "${CNC}"
	}
fi

sleep 1
clear

# Intalling tdrop for scratchpads
logo "Installing Tdrop"
	if command -v tdrop >/dev/null 2>&1; then
		printf "\n%s%sTdrop is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "\n%s%sInstalling tdrop%s\n" "${BLD}" "${CBL}" "${CNC}"
		yay -S tdrop-git --noconfirm
	fi

sleep 1
clear

# Intalling xqp
logo "Installing xqp"
	if command -v xqp >/dev/null 2>&1; then
		printf "\n%s%sxqp is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "\n%s%sInstalling xqp%s\n" "${BLD}" "${CBL}" "${CNC}"
		yay -S xqp --noconfirm
	fi
	
sleep 1
clear

# Installing Brave
logo "Installing Brave"
	if command -v brave >/dev/null 2>&1; then
        printf "\n%s%sBrave is already installed%s\n" "${BLD}" "${CGR}" "${CNC}"
    else
		printf "\n%s%sInstalling Brave%s\n" "${BLD}" "${CBL}" "${CNC}"
        yay -S brave-bin --noconfirm
	fi

sleep 1
clear

########## --------- Enabling MPD service --------- ##########

logo "Enabling mpd service"

# Checking if the mpd service is enabled globally
	if systemctl is-enabled --quiet mpd.service; then
		printf "\n%s%sDisabling and stopping the global mpd service%s\n" "${BLD}" "${CBL}" "${CNC}"
		sudo systemctl stop mpd.service
		sudo systemctl disable mpd.service
	fi

printf "\n%s%sEnabling and starting the user-level mpd service%s\n" "${BLD}" "${CYE}" "${CNC}"
systemctl --user enable --now mpd.service

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2
clear

########## --------- Updating user-dirs.dirs --------- ##########

xdg-user-dirs-update

########## --------- Changing shell to zsh --------- ##########

logo "Changing default shell to zsh"

	if [[ $SHELL != "/usr/bin/zsh" ]]; then
		printf "\n%s%sChanging your shell to zsh. Your root password is needed.%s\n\n" "${BLD}" "${CYE}" "${CNC}"
		# Changing the shell to zsh
		chsh -s /usr/bin/zsh
		printf "%s%sShell changed to zsh. Please reboot.%s\n\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sYour shell is already zsh\nGood bye! installation finished, now reboot%s\n" "${BLD}" "${CGR}" "${CNC}"
	fi
zsh