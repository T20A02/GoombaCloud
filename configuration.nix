{ config, pkgs, lib,... }:

{
  imports = 
  [
  ./hardware-configuration.nix	
  ];
  # Booloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;

  networking.hostName = "nixtop";
  
  # XDG Portals
  xdg = {
    autostart.enable = true;
    portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };


  # Hardware
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-vaapi-driver
        intel-media-driver
        libvdpau-va-gl
        intel-gpu-tools
        cudatoolkit
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
      setLdLibraryPath = true;
    };
    nvidia = {
      modesetting.enable = true;
      open = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      forceFullCompositionPipeline = true;
      powerManagement.enable = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      prime = {
        offload = {
      	  enable = true;
      	  enableOffloadCmd = true;
        };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:58:0:0";
      };
    };
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
  };
  
  # Audio Service
  services = {
    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
  };


  # Services
  services = {
    libinput.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      excludePackages = [ pkgs.xterm ];
      videoDrivers = ["iHD" "i965" "nvidia"];
      displayManager.sessionCommands = ''
          ${lib.getBin pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource 2 0
      '';
      displayManager.gdm = {
        enable = true;
        wayland = true;
        };
      };
    dbus.enable = true;
    gvfs.enable = true;
    tumbler.enable = true;
    blueman.enable = true;
    gnome = {
      sushi.enable = true;
      gnome-keyring.enable = true;
    };
  };

  hardware.openrazer.enable = true;

  security.rtkit.enable = true;
  networking.networkmanager.enable = true;

  programs = {
    hyprland = {
      enable = true;
    };
    waybar.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = true;
    };
  };

  
  #Fonts
     fonts = {
      packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      source-han-sans
      open-sans
      source-han-sans-japanese
      source-han-serif-japanese
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" "Source Han Serif" ];
      sansSerif = [ "Open Sans" "Source Han Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  # Start Waybar
  
  # User
  users.users.goomba = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "openrazer" "plugdev"];
    home = "/home/goomba";
  	packages = with pkgs; [
  	  discord
  	  intel-gpu-tools
  	  lshw
  	  spotify
  	  rpi-imager
  	  brightnessctl
  	  mattermost-desktop
  	  cbonsai
  	  asciiquarium-transparent
  	  hashcat
  	  nvtopPackages.full
      steam
      python3
      glibc
      minecraft
      brightnessctl
      blueberry
      jdk
  	];
  };

  # Default Console
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  # Yubikey Agent
  services.yubikey-agent.enable = true;
  services.pcscd.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    kitty
    micro
    polkit_gnome
    libva-utils
    fuseiso
    udiskie
    gnome.adwaita-icon-theme
    gnome.gnome-themes-extra
    nvidia-vaapi-driver
    gsettings-desktop-schemas
    swaynotificationcenter
    wlr-randr
    ydotool
    wl-clipboard
    hyprland-protocols
    hyprpicker
    swayidle
    swaylock
    xdg-desktop-portal-hyprland
    hyprpaper
    wofi
    firefox-wayland
    swww
    grim
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    qt5.qtwayland
    qt6.qmake
    qt6.qtwayland
    adwaita-qt
    adwaita-qt6
    pamixer
    grimblast
    qview
    pciutils
    btop
    neofetch
    blueberry
    yubikey-agent
    openrazer-daemon
    polychromatic
    glibc
  ];

  environment.sessionVariables = {
    POLKIT_AUTH_AGENT = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    GSETTINGS_SCHEMA_DIR = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    CLUTTER_BACKEND = "wayland";
#    WLR_RENDERER = "vulkan";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
  }; 
  system.stateVersion = "23.11";
}
