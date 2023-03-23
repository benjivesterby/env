FROM ubuntu:22.04

# Disable prompt during package installation
ARG GO_VERSION=1.20

ENV DEBIAN_FRONTEND=noninteractive 
ENV TZ=Etc/UTC 

# Set the working directory
WORKDIR /

# Install required packages
RUN apt-get update && \
    apt-get install -y git curl ca-certificates software-properties-common tzdata

RUN add-apt-repository -y ppa:git-core/ppa

RUN echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | tee /etc/apt/sources.list.d/goreleaser.list


RUN add-apt-repository -y ppa:wireshark-dev/stable

RUN apt-get update && \
    apt-get install -y net-tools nscd tmux \
            autotools-dev ecryptfs-utils cryptsetup \
            ng-common gcc g++ make python3 python3-pip \
            tree kazam nmap graphviz network-manager-l2tp \
            scdaemon pcscd python-is-python3 \
            shellcheck xclip libpam-u2f \
            build-essential linux-headers-generic \
            make clang llvm libelf-dev libpcap-dev wireguard \
            tcpdump wireshark goreleaser suricata tshark apt-listchanges \
            zsh jq pre-commit lua-nvim clangd

RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz

RUN tar xzvf nvim-linux64.tar.gz -C /root

RUN rm nvim-linux64.tar.gz

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN mkdir /root/.zsh
RUN curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
RUN curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh

RUN export SHELL=/bin/zsh

SHELL ["/bin/bash", "--login", "-i", "-c"]
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
RUN source /root/.bashrc && nvm install --lts
SHELL ["/bin/bash", "--login", "-c"]

#RUN npm install -g npm && \
#	npm install -g typescript-language-server typescript lighthouse \
#            lighthouse-batch broken-link-checker tree-sitter-cli keywordsextract

RUN mkdir /root/bin

RUN curl -L https://github.com/devnw/gvm/releases/download/latest/gvm \
    > /root/bin/gvm && chmod +x /root/bin/gvm

RUN /root/bin/gvm ${GO_VERSION} -s; exit 0
RUN source /root/.bashrc 

RUN go install golang.org/x/tools/...@latest
RUN go install github.com/shirou/gopsutil/...@latest
RUN go install golang.org/x/perf/cmd/benchstat@latest

RUN git config --global core.editor "nvim"
RUN git config --global push.autoSetupRemote true
RUN git config --global rerere.enabled true
RUN git config --global pull.rebase true
RUN git config --global init.defaultBranch main 
RUN git config --global push.autoSetupRemote true 
RUN git config --global credential.helper store

RUN git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm

RUN curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf

RUN ~/.fzf/install --all

RUN git clone https://github.com/github/copilot.vim.git \
		~/.config/nvim/pack/github/start/copilot.vim


RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)"/bin v1.37.1
RUN golangci-lint --version
RUN pre-commit init-templatedir ~
RUN pip3 install --user --upgrade pip
RUN pip3 install --user --upgrade pynvim
RUN pip3 install -U Commitizen

COPY ./nvim /root/.config/nvim
COPY ./bin/* /root/bin/
COPY ./.tmux.conf.local /root
COPY ./.tmux.conf /root

COPY ./.env.shared /root
RUN chmod +x /root/.env.shared

COPY ./.env.bash /root
RUN chmod +x /root/.env.bash
RUN echo "source ~/.env.bash" >> ~/.zshrc

# Execute the env.sh script
RUN /bin/bash 
