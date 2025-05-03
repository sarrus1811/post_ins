#!/bin/bash

function upgrade(){
	echo "Updating and upgrading..."
        sleep 1
        apt update && apt upgrade -y
	apt dist-upgrade
	apt autoremove && apt autoclean -y
        echo "Done upgrading"
}

function admin_tools(){
	echo "Setting up administrative tools..."
	sleep 1
	apt install bleachbit htop terminator curl wget net-tools openssh-server openssh-client -y
	echo "Done..."
}

function dev_tools(){
	echo "Setting up developer tools..."
	sleep 1
	apt install emacs build-essential git golang ruby-full python3 wget gpg gdb valgrind -y
     
	# Install VScode
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
	sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
	sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
	rm -f packages.microsoft.gpg
	apt install apt-transport-https
	apt update
	apt install code # or code-insiders

 	# Install Docker
  	# Add Docker's official GPG key:
	sudo apt-get update
	sudo apt-get install ca-certificates curl
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	# Add the repository to Apt sources:
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
 	# Finally install Docker
  	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

function display_options(){
	echo "1) Setup Everything"
	echo "2) Update and Upgrade"
	echo "3) Install Administrative tools" 
	echo "4) Set up Developer environment" 
	echo "5) Quit"
}

PS3="Select an option:"

select ITEM in "Setup Everything" "Update and upgrade" "Install administrative tools" "Set up Developer environment" "Quit"; do
	case $REPLY in 
		1)	
			upgrade
			admin_tools
			dev_tools
			;;
		2)	
			upgrade
			;;
		3)
			apt update
			admin_tools
			;;
		4)
			apt update
			dev_tools
			;;
		5)
			echo "Quitting..."
                	sleep 1
                	exit
			;;
		*)
			echo "Invalid option!"
			display_options
	esac
done

