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
    echo "Installing docker..."
    sleep 1
    sudo xbps-install -S docker -y
}

function vscode_install(){
    sudo xbps-install -S vscode -y
    sleep 1
}

function tmux_setup(){
    sudo xbps-install -S tmux -y
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    mkdir -p ~/.config/tmux/plugins/catppuccin
    git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
    git clone https://github.com/sarrus1811/
    tmux source ~/.tmux.conf
}

function ghostty_setup(){
    echo "Installing ghostty..."
    sudo xbps-install -S ghostty -y
    # -- Configure Ghostty --
    printf "background = 2d2139\n" >> ~/.config/ghostty/config
    printf "#background = 25003e\n"  >> ~/.config/ghostty/config
    printf "#foreground = ffffff\n" >> ~/.config/ghostty/config
    printf "\n"
    printf "font-family = \n"
    printf "\n"
    printf "keybind = ctrl+shift+w=close_surface\n" >> ~/.config/ghostty/config
}

function flathub_setup(){
    "Setting up flatpacks..."
    sudo xbps-install -S flatpak -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    echo "Restart for changes to take effect..."
    sleep 1
}

function podman_setup(){
    echo "Installing podman..."
    sudo xbps-install podman buildah skopeo -y
    echo "Done..."
}

function js_setup(){
    echo "Installing node..."
    sleep 1
    sudo xbps-install -S nodejs -y
    sudo npm install -g typscript
    sudo npm install -g typescript-language-server
    echo "Done..."
}

function bash_setup(){
    echo "Setting up Bash language server..."
    sleep 1
    sudo npm install -g bash-language-server
    echo "Done..."
}

function ruby_setup(){
    echo "Setting up Ruby tools..."
    sleep 1
    curl -fsSL https://rbenv.org/install.sh | bash
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    sudo xbps-install -S libffi-devel libyaml-devel openssl-devel readline-devel zlib-devel
    rbenv install 3.4.5
    rbenv global 3.4.5
    gem install bundler
    gem install ruby-lsp
    rbenv rehash
    echo "Done..."
}

function go_setup(){
    echo "Installing Go tools..."
    sleep 1
    xbps-install -S go -y
    go install golang.org/x/tools/gopls@latest
    echo "Done..."
}

function c_setup(){
    echo "Installing C/C++ tools..."
    sleep 1
    xbps-install -S clang clang-tools-extra -y
    echo "Done..."
}

function python_setup(){
    sleep 1
    curl -LsSf https://astral.sh/uv/install.sh | sh
    uv pip install pyright
}

function rust_setup(){
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

function upgrade(){
    echo "Updating and upgrading..."
    sleep 1
    sudo xbps-remove -R firefox firefox-esr -y
    sudo xbps-install -Su -y
    sudo xbps-remove -oO -y
    echo "Done upgrading"
}

function setup_fonts(){
    echo "Setting up fonts..."
    sleep 1
    git clone https://github.com/sarrus1811/fonts
    cd fonts
    mkdir Hack Fira_Code JetBrainsMono Recursive Mononoki
    unzip Hack-v3.003-ttf.zip -d Hack/
    unzip JetBrainsMono-2.304.zip  -d JetBrainsMono/
    unzip Fira_Code.zip -d Fira_Code/
    unzip Recursive.zip -d Recursive/
    unzip mononoki.zip -d Mononoki/
    sudo cp Hack/ttf/*.ttf /usr/share/fonts/TTF/
    sudo cp JetBrainsMono/fonts/ttf/*.ttf /usr/share/fonts/TTF/
    sudo cp Fira_Code/static/*.ttf /usr/share/fonts/TTF/
    sudo cp Recursive/static/*.ttf /usr/share/fonts/TTF/
    sudo cp Mononoki/*.ttf /usr/share/fonts/TTF/
    sudo fc-cache -fv
    sleep 1
    echo "Done..."
}

function admin_tools(){
    echo "Setting up administrative tools..."
    sleep 1
    mkdir temp
    cd temp
    sudo xbps-install -S bleachbit btop unzip curl wget net-tools openssh-server openssh-client zoxide fzf chromium -y
    flatpak_install
    js_setup
    bash_setup
    # -- setup zoxide
    echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
    source ~/.bashrc
    cd ~
    sudo rm -rf temp
    # flatpak install flathub engineer.atlas.Nyxt
    echo "Done..."
}

function dev_tools(){
    echo "Setting up developer tools..."
    sleep 1
    sudo xbps-install -S emacs-x11-30.2_1 git wget gpg base-devel -y
    tmux_setup
    ghostty_setup
    vscode_install
    docker_install
    ruby_setup
    echo "Done..."
}

function display_menu(){
    echo "1. Quick setup; Setup Everything"
    echo "2. Update and Upgrade"
    echo "3. Install Administrative tools"
    echo "4. Set up Developer environment"
    echo "5. Install tool(s)"
    echo "6. Quit"
}

TASKS=("bash" "ruby" "python" "go" "js" "c" "rust" "docker" "podman" "vscode" "flatpak" "zed" "list")

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
            sudo xbps-install -S
            admin_tools
            ;;
        4)
            sudo xbps-install -S
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
   echo " -i  - Install tool(s) by name"
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
