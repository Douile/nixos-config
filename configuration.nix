# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, modulesPath, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (modulesPath + "/profiles/hardened.nix") 
    ];

  # Kernel configuration
  boot.kernelParams = [ "lockdown=confidentiality" ];
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 2;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only
  boot.loader.grub.gfxpayloadBios = "keep";
  boot.loader.grub.gfxmodeBios = "1920x1080";

  # Filesystems
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "defaults" "hidepid=2" "gid=proc" ];
  };

  # Security
  security.apparmor = {
    enable = true;
  };

  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus8";
  #   keyMap = "uk";
    useXkbConfig = true; # use xkbOptions in tty.
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "gb";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "video" ];
  };

  users.groups.proc = {};

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    htop-vim
    graphene-hardened-malloc
    alacritty
    hack-font
    luna-icons
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Neovim config
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    configure = {
      customRC = ''
      set nu
      set ts=2 sw=2 et
      syntax on
      '';

      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ fugitive airline vim-nix ];
      };
    };
  };

  # Zsh config
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestions = {
      enable = true;
      async = true;
    };
  };

  # OhMyZsh config
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [
      "git"
      "golang"
      "rust"
      "docker"
      "node"
      "npm"
      "man"
      "aliases"
      "sudo"
      "command-not-found"
    ];
    theme = "alanpeabody";
    customPkgs = with pkgs; [
      nix-zsh-completions
      zsh-completions
      zsh-autosuggestions
    ];
  };

  # List services that you want to enable:

  # Proc for logind
  systemd.services.systemd-logind.serviceConfig = {
    SupplementaryGroups = "proc";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable vdagent
  services.spice-vdagentd.enable = true;

  # XServer
  services.xserver = {
    resolutions = [ { x = 1920; y = 1080; } ];
    displayManager = {
      sddm = {
        enable = true;
        settings.Autologin = {
          User = "user";
          Session = "awesome.desktop";
        };
        enableHidpi = true;
      };
      defaultSession = "none+awesome";
    };
    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks
        luadbi-mysql
      ];
    };
  };

  # etc files
  ##environment.etc."xdg/awesome/rc.lua".text = ''

  ##'';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable auto updates
  system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

