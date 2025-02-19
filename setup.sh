#!/usr/bin/env bash
# Originally created by	- https://github.com/gh0stzk

CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.ricebackup
date=$(date +%Y%m%d-%H%M%S)

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

########## ---------- Welcome ---------- ##########

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

printf '%s%sInstalling needed packages..%s\n\n' "${CNC}" "${CRE}" "${CNC}"

dependencies=(alacritty base-devel brightnessctl bspwm dunst feh git imagemagick jgmenu \
              libnotify libwebp eza maim mpc mpd ncmpcpp neofetch neovim \
              pacman-contrib pamixer papirus-icon-theme physlock picom playerctl \
	       	  polkit-gnome polybar ranger rofi sxhkd tealdear \
	      	  ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
              ueberzug webp-pixbuf-loader xclip xdg-user-dirs xdo xdotool \
	      	  xorg-xdpyinfo xorg-xkill xorg-xprop xorg-xrandr xorg-xsetroot xorg-xwininfo \
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

########## ---------- Cloning the Rice! ---------- ##########

printf '%s%sDownloading dotfiles.%s\n\n' "${CNC}" "${CRE}" "${CNC}"

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

printf '%s%sBackup files%s\n\n' "${CNC}" "${CRE}" "${CNC}"
printf "Backup files will be stored in %s%s%s/.ricebackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 10

if [ ! -d "$backup_folder" ]; then
  mkdir -p "$backup_folder"
fi

for folder in alacritty bspwm dunst jgmenu mpd ncmpcpp picom polybar ranger rofi sxhkd zsh; do
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

printf '%s%sInstalling dotfiles..%s\n\n' "${CNC}" "${CRE}" "${CNC}"
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
[ ! -d ~/.local/share/fonts ] && mkdir -p ~/.local/share/fonts
[ ! -d ~/.local/share/asciiart ] && mkdir -p ~/.local/share/asciiart
[ ! -d ~/.local/share/assets ] && mkdir -p ~/.local/share/assets
[ ! -d ~/desk ] && mkdir -p ~/desk
[ ! -d ~/down ] && mkdir -p ~/down
[ ! -d ~/docs ] && mkdir -p ~/docs
[ ! -d ~/music ] && mkdir -p ~/music
[ ! -d ~/pics ] && mkdir -p ~/pics
[ ! -d ~/vids ] && mkdir -p ~/vids
[ ! -d ~/games ] && mkdir -p ~/games

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

xdg-user-dirs-update
echo "Creating xdg-user-dirs"
sleep 1

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
  cp -R "${files}" $(xdg-user-dir PICTURES)
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

printf '%s%sInstalling Yay, Tdrop, xqp, and Librewolf.%s\n\n' "${CNC}" "${CRE}" "${CNC}"
sleep 2
clear

# Installing yay
printf '%s%sInstalling Yay%s\n\n' "${CNC}" "${CRE}" "${CNC}"
	if command -v yay >/dev/null 2>&1; then
		printf "%s%sYay is already installed.%s" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sInstalling Yay.%s" "${BLD}" "${CBL}" "${CNC}"
		{
			cd "$HOME" || exit
			git clone https://aur.archlinux.org/yay.git
			cd yay || exit
			makepkg -si --noconfirm
		} && {
			cd "$HOME" || exit
			rm -rf yay
		} || {
		printf "\n%s%sFailed to install Yay.%s" "${BLD}" "${CRE}" "${CNC}"
	}
fi

sleep 1
clear

# Intalling tdrop for scratchpads
printf '%s%sInstalling Tdrop%s\n\n' "${CNC}" "${CRE}" "${CNC}"
	if command -v tdrop >/dev/null 2>&1; then
		printf "%s%sTdrop is already installed.%s" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sInstalling Tdrop.%s" "${BLD}" "${CBL}" "${CNC}"
		yay -S tdrop-git --noconfirm
	fi

sleep 1
clear

# Intalling xqp
printf '%s%sInstalling xqp%s\n\n' "${CNC}" "${CRE}" "${CNC}"
	if command -v xqp >/dev/null 2>&1; then
		printf "%s%sXqp is already installed.%s" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sInstalling xqp.%s" "${BLD}" "${CBL}" "${CNC}"
		yay -S xqp --noconfirm
	fi
	
sleep 1
clear

# Installing Brave
printf '%s%sInstalling Librewolf%s\n\n' "${CNC}" "${CRE}" "${CNC}"
	if command -v librewolf >/dev/null 2>&1; then
        	printf "%s%sLibrewolf is already installed.%s" "${BLD}" "${CGR}" "${CNC}"
    	else
		printf "%s%sInstalling Librewolf.%s" "${BLD}" "${CBL}" "${CNC}"
        	yay -S librewolf-bin --noconfirm
	fi

sleep 1
clear

########## --------- Enabling MPD service --------- ##########

if systemctl is-enabled --quiet mpd.service; then
    printf "\n%s%sDisabling and stopping the global mpd service%s\n" "${BLD}" "${CBL}" "${CNC}"
    sudo systemctl stop mpd.service
    sudo systemctl disable mpd.service
fi

printf "\n%s%sEnabling and starting the user-level mpd service%s\n" "${BLD}" "${CYE}" "${CNC}"
systemctl --user enable --now mpd.service
sleep 2
clear

########## --------- Changing shell to zsh --------- ##########

printf '%s%sChanging default shell to zsh%s\n\n' "${CNC}" "${CRE}" "${CNC}"

	if [[ $SHELL != "/usr/bin/zsh" ]]; then
		printf "\n%s%sChanging your shell to zsh. Your root password is needed.%s\n\n" "${BLD}" "${CYE}" "${CNC}"
		# Changing the shell to zsh
		chsh -s /usr/bin/zsh
		printf "%s%sShell changed to zsh. Please reboot.%s\n\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sYour shell is already zsh\nGood bye! installation finished, now reboot%s\n" "${BLD}" "${CGR}" "${CNC}"
	fi
zsh
