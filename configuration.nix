# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      <home-manager/nixos>
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  swapDevices =
    [ { device = "/dev/disk/by-uuid/12f17ac7-8f52-44d7-8622-00a072312160"; }
    ];

  networking.hostName = "Gopher"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  hardware.nvidia.modesetting.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.powerManagement.enable = true;
  services.xserver.screenSection = ''
    Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    Option         "AllowIndirectGLXProtocol" "off"
    Option         "TripleBuffer" "on"
  '';

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
    displayManager = {
	gdm.enable = true;
    };
    desktopManager = {
	gnome.enable = true;
	xfce.enable = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.hardware.bolt.enable = true;
  security.rtkit.enable = true;
  #services.pipewire = {
  #  enable = true;
  #  alsa.enable = true;
  #  alsa.support32Bit = true;
  #  pulse.enable = true;
  #  # If you want to use JACK applications, uncomment this
  #  #jack.enable = true;

  #  # use the example session manager (no others are packaged yet so this is enabled by default,
  #  # no need to redefine it in your config for now)
  #  #media-session.enable = true;
  #};

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.benji = {
    isNormalUser = true;
    description = "Benji Vesterby";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    packages = with pkgs; [
      firefox
      plasma5Packages.plasma-thunderbolt
      slack
      libpcap
    #  thunderbird
    ];
  };

  #home-manager.users.benji = { pkgs, ... }: {

  #      home.packages = with pkgs; [

  #      	go_1_18

  #      ];
  #};


  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = false;
  services.xserver.displayManager.autoLogin.user = "benji";
  services.logind.extraConfig = "HandleLidSwitchExternalPower=ignore";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  #services.xserver.videoDrivers = [ "nvidia" ];# [ "intel" "nvidia" ];
  hardware.opengl.enable = true;

  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Terminals
    alacritty
    kitty

    # Utilities
    bash
    git
    wget
    curl
    jq
    dig
    ripgrep
    python3
    python3.pkgs.pip
    nettools
    gnupg
    pinentry-curses
    tmux
    cryptsetup
    gcc 
    tree
    kazam
    nmap
    xclip
    llvm
    htop                               # System monitor
    ffmpeg
    mplayer                            # Video player
    imagemagick                        # Image manip library
    arandr                             # GUI frontend for xrandr monitor configuration
    rustc                              # Rust programming language
    bc                                 # Basic calculator
    irssi                              # Irc client
    sqlite                             # sqlite database
    unzip                              # .zip file util
    scrot                              # Screenshot capturing

    # Editors
    neovim
    goreleaser

    # Docker
    docker
    docker-compose
    containerd

    # Packet Capture
    wireshark
    tcpdump
    libpcap

    # Linting
    shellcheck
    pre-commit
    golangci-lint

    # Other
    terraform
    graphviz
    wireguard-tools
    signal-desktop
    signal-cli
    hugo
    keybase
    steam                              # Games
    nodejs


    libcap
    go_1_18
  ];

  services.pcscd.enable = true;
  programs.gnupg.agent = {
     enable = true;
     pinentryFlavor = "curses";
     enableSSHSupport = true;
  };

  #system.activationScripts = {
  #  localBin = {
  #    text = ''
  #    '';
  #    deps = [];
  #  };
  #};

  environment.variables.EDITOR = "nvim";
  programs.neovim.enable = true;
  programs.neovim.viAlias = true;
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.extraGroups.vboxusers.members = [ "benji" ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -al";
      update = "sudo nixos-rebuild switch";
      vi = "nvim";
      vim = "nvim";
      v = "nvim";
    };
    #history = {
    #  size = 10000;
    #  path = "${config.xdg.dataHome}/zsh/history";
    #};
    ohMyZsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
