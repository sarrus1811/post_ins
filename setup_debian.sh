#!/usr/bin/env bash

###############################################################
# --- Post installtion script ---
# 
# Install and setup most used programs #
# #
# --- Change History ---
# #
###############################################################

function docker_install() {
    # -- Install Docker --
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

function vscode_install(){
    # Install VScode
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f packages.microsoft.gpg
    sudo apt install apt-transport-https
    sudo apt update
    sudo apt install code # or code-insiders

    # Install VScode extensions
    # echo "Setting up VScode extensions"
    # code --no-sandbox --disable-gpu-sandbox --user-data-dir=/home/$USER/.vscode/ --install-extension ms-python.python
    echo "Done..."
}
 
function flatpak_install(){
    sudo apt install flatpak
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
}

function podman_setup(){
    sudo apt install podman -y
}

function js_setup(){
    echo "Setting up nvm..."
    sleep 1
    sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    if [[ $(command -v nvm) != "nvm" ]]; then
	echo "nvm installation failed..."
    fi
    echo "Installing node..."
    nvm install --lts
}

function bash_setup(){
    sleep 1
    sudo npm install -g bash-language-server
}

function ruby_setup(){
    sleep 1
    sudo apt install ruby-full ruby-bundler -y
    sudo gem install ruby-lsp

    # sudo bash -c "
    # printf '%s\n' '
    # # Function to create and populate a Gemfile
    # function gemfile_make() {
    # 	touch Gemfile
    # 	printf ''''%s\n'''' ''''
    # 	# Gemfile
    # 	source \"https://rubygems.org\"
    # 	# ... other gems ...
    # 	group :development, :test do
    # 	gem \"ruby-lsp\" # Add this line
    # 	# gem \"rubocop\", require: false # For linting via Ruby LSP
    # 	end
    # 	'''' >> Gemfile
    # }
    # ' >> \"$USER/.bashrc\"
    # "
}

function go_setup(){
    sleep 1
    sudo apt install golang-go gopls -y
}

function c_setup(){
    sleep 1
    sudo apt install build-essential gdb valgrind clangd -y
}

function python_setup(){
    sleep 1
    sudo apt install python3 python3-venv
    npm install -g pyright
}

function rust_setup(){
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

function upgrade(){
    echo "Updating and upgrading..."
    sleep 1
    sudo apt remove firefox firefox-esr
    apt update && apt upgrade -y
    apt dist-upgrade
    apt autoremove && apt autoclean -y
    echo "Done upgrading"
}

function admin_tools(){
    echo "Setting up administrative tools..."
    sleep 1
    sudo apt install bleachbit htop terminator tmux curl wget net-tools openssh-server openssh-client chromium -y
    sudo js_setup
    sudo bash_setup
    flatpak_install
    echo "Done..."
}

function dev_tools(){
    echo "Setting up developer tools..."
    sleep 1
    apt install emacs git wget gpg -y
    vscode_install
    docker_install
    ruby_setup
}

function display_menu(){
    echo "1. Quick setup; Setup Everything"
    echo "2. Update and Upgrade"
    echo "3. Install Administrative tools"
    echo "4. Set up Developer environment"
    echo "5. Install tool(s)"
    echo "6. Quit"
}

TASKS=("bash" "ruby" "python" "go" "js" "c" "rust" "docker" "podman" "vscode" "flatpak" "list")

function display_tasks(){
    echo "--Available tasks--"
    for task in "${!TASKS[@]}"; do
	echo "$task"
    done
}

function setup_tools(){
    echo "Type list to list all options."
    echo "Setup tools for:"
    read -a task_list
    for i in "${!task_list[@]}"; do
	if [[ "${task_list[i]}" != "list" ]] ; then
	    echo "Setting up:"
	    echo "${task_list[i]}"
	else
	    display_tasks
	fi
    done
}

install_tool() {
    local TOOL="$1" # Assign the first argument to a local variable

    case "$TOOL" in
        bash)
            echo "Setting up Bash..."
            bash_setup	      
            ;;
        js)
            echo "Setting up JavaScript..."
            js_setup
            ;;
        ruby)
            echo "Setting up Ruby..."
            ruby_setup
            ;;
        go)
            echo "Setting up Go..."
            go_setup
            ;;
        c)
            echo "Setting up C/C++ tools..."
            c_setup
            ;;
        python)
            echo "Setting up Python..."
            python_setup
            ;;
        rust)
            echo "Setting up Rust..."
            rust_setup
            ;;
        docker)
            echo "Setting up Docker..."
            docker_setup
            ;;
        podman)
            echo "Setting up Podman..."
            podman_setup
            ;;
        vscode)
            echo "Setting up VSCode..."
            vscode_setup
            ;;
	    zed)
            echo "Setting up Zed..."
            sudo curl -f https://zed.dev/install.sh | sh
	    ;;
        flatpak)
            echo "Setting up Flathub..."
            flatpak_setup
            ;;
        list)
            echo "Listing available tools:"
            display_tasks
            ;;
        *)
            echo "Error: Invalid tool option '$TOOL'. Use 'list' to see available options." >&2
            return 1 # Indicate an error
            ;;
    esac
    return 0 # Indicate success
}

function menu(){
    PS3="Select an option:"
    select ITEM in "Quick Setup" "Update and upgrade" "Install administrative tools" "Set up Developer environment" "Install Tool" "Quit"; do
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
		setup_tools
		;;

	    6)
		echo "Quitting..."
		sleep 1
		exit
		;;
	    *)
		echo "Invalid option!"
	        display_menu
	esac
    done
}

help()
{
   # Display Help
   echo "Syntax: setup.sh [-u|-q|-d|-i|-m|-h]"
   echo "options:"
   echo " -q  - Quick setup; updates and installs everything"
   echo " -d  - Setup developer environment"
   echo " -i  - Install specified tool(s)"
   echo " -m  - Run the menu"
   echo " -h  - Display this message"
   echo
}


# --- Program starts here ---

USER="$(whoami)"
echo "Running script for user $USER..."

if [[ "$#" -eq 0 ]]; then
    echo "No arguments given..."
    help
    exit 0 # Exit after showing help if no options are mandatory
fi

while getopts "qdmhi:" opt; do
    case $opt in
	q)
	    upgrade
	    admin_tools
	    dev_tools
	    ;;
	d)
	    apt update
	    dev_tools
	    ;;
	i)
	    TOOL=$OPTARG
	    install_tool $TOOL
	    ;;
	m)
	    menu
	    ;;
	h)
	    help
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG requires an argument." >&2
	    exit 1
	    ;;
    esac
done
