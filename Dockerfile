FROM archlinux:multilib-devel

ARG USERNAME="user"

# Update and install dependencies
RUN pacman -Syu --noconfirm && pacman --noconfirm --needed -S \
    fzf git neovim ripgrep tmux unzip wget zsh tldr\
    make gcc \
    npm go python3 

# User setup
RUN useradd -m -G users,audio,lp,optical,storage,video,wheel,power  ${USERNAME} -s /usr/sbin/zsh
RUN passwd -d ${USERNAME}
RUN echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Change user
USER ${USERNAME}

# Install oh-my-zsh for user 
# RUN echo "bindkey -v" >> ~/.zshsc
# RUN echo "export VI_MODE_SET_CURSOR=true" >> ~/.zshsc
RUN bash -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
COPY dotfiles/.zshrc ${HOME}/temp.zshrc
RUN cat ${HOME}/temp.zshrc >> ${HOME}/.zshrc && rm -f ${HOME}/temp.zshrc 

# Install neovim kickstart
RUN mkdir -p ${HOME}/.config/nvim && chmod 777 ${HOME}/.config/nvim
ADD .config/nvim/init.lua ${HOME}/.config/nvim
RUN nvim --headless "+Lazy! sync" "+TSUpdateSync" "+MasonToolsUpdateSync" +qa

RUN mkdir ${HOME}/dev && chown ${USERNAME} ${HOME}/dev
