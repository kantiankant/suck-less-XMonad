# suck-less-XMonad
My XMonad configuration. It works (in theory)

## What's in here
| Directory | What it does |
|-----------|-------------|
| `xmonad/` | The window manager config |
| `alacritty/` | Terminal emulator. Fast. Doesn't crash. |
| `picom/` | Compositor. Makes things look nice. Purely cosmetic. |
| `nvim/` | Text editor config. Black and white colourscheme because I've given up on joy |
| `fastfetch/` | Tells you what computer you're on. Useful if you've forgotten. Or been asked to clear your desk |

## Dependencies

### Window manager
```
xmonad xmonad-contrib ghc stack
```
`xmonad` and `xmonad-contrib` are managed via Stack because the AUR versions lag behind and I've had quite enough of things lagging behind without my permission.

### Bar (Quickshell)
```
quickshell qt6-base qt6-declarative qt6-svg
```

### Bar functionality
```
iwd xprop xdotool pactl pamixer playerctl brightnessctl
```
`pactl` handles volume. `pamixer` handles mute toggling. `playerctl` for media keys. `brightnessctl` for screen brightness. `xprop` watches for workspace changes. `xdotool` switches them. `iwd` because NetworkManager is someone else's problem and I've got enough of my own.

### Applications
```
alacritty rofi firefox yazi impala
```

### Screenshots
```
maim xclip
```
`maim -s` handles region selection internally. No separate `slop` required, contrary to what I said previously. I was wrong. It happens. Less often than being made redundant, but it happens.

### Compositor and wallpaper
```
picom xwallpaper
```
Both launched at startup. Wallpaper is hardcoded. See Notes.

### Volume overlay
```
xob
```
The startup hook creates a named pipe at `/tmp/xob-vol`. Volume and brightness keys write a percentage to it. `xob` reads from it and draws a bar. Elegant in theory. Absolutely fine in practice once you've got it running, which takes longer than it should.

### Logout
```
wlogout
```
Power button in the bar. Left click opens it. Middle click suspends via `systemctl suspend`. If you're not on systemd, sort that out yourself. I've said my piece on this topic in other places and I'm not repeating it (uhh I'll remove it later because uhhh wlogout is Wayland-only).

### Fonts
```
ttf-jetbrains-mono-nerd
apple-fonts
noto-fonts-emoji
ttf-nerd-fonts-symbols
```
The bar uses `JetBrainsMono Nerd Font` for all glyphs and `SF Pro Text` (from `apple-fonts`) for the clock and workspace numbers. If either is missing you'll get boxes where icons should be. Sad little empty boxes. Staring at you. I know the feeling.

**Must be the Nerd Font variant of JetBrains Mono.** The regular one will give you nothing but grief.

### Nerd Font glyph sets used
- `nf-md-battery_*` — battery widget
- `nf-md-wifi_*` — network widget
- `nf-md-volume_*` — volume widget
- `nf-md-power_standby` — power button
- `nf-fa-star` — launcher button

### Neovim
```
neovim
```
Plugins managed internally. Colourscheme is black and white. On purpose. Don't.

### X11 input
```
xorg-server xorg-xinput libinput xf86-input-libinput
```
Touchpad configuration. Skip if you're on a desktop. If you're on a ThinkPad running XMonad, you already know why you need this.

## Installation
```bash
git clone https://github.com/kantiankant/suck-less-XMonad ~/.config/suck-less-XMonad
```

Symlink what you want:
```bash
ln -sf ~/.config/suck-less-XMonad/xmonad ~/.xmonad
ln -sf ~/.config/suck-less-XMonad/alacritty ~/.config/alacritty
ln -sf ~/.config/suck-less-XMonad/picom ~/.config/picom
ln -sf ~/.config/suck-less-XMonad/nvim ~/.config/nvim
```

Build xmonad:
```bash
cd ~/.xmonad && xmonad --recompile
```
If it errors, read the error. If you can't read Haskell, that's not my problem. It's probably an indentation issue. It's always an indentation issue.

## Updating
There's a script for that:
```bash
xmonad-update
```
Updates Stack, fetches the latest xmonad and xmonad-contrib from Hackage, patches the stack.yaml, rebuilds, and insults you based on the outcome. Install it:
```bash
sudo cp xmonad-update.sh /usr/local/bin/xmonad-update
sudo chmod +x /usr/local/bin/xmonad-update
```

## Keybindings
The important ones. There are others. Read the config if you're that interested.

| Key | Action |
|-----|--------|
| `M-q` | Terminal |
| `M-Space` | Rofi launcher |
| `M-Return` | Firefox |
| `M-e` | Yazi file manager |
| `M-w` | Close window |
| `M-S-r` | Recompile and restart xmonad |
| `M-S-e` | Exit xmonad entirely, into the void |
| `M-f` / `M-n` | Next layout |
| `M-c` | First layout |
| `M-Tab` | Toggle last workspace |
| `M-hjkl` | Focus windows |
| `M-S-hjkl` | Move windows |
| `M--` / `M-=` | Shrink / expand master |
| `M-i` / `M-p` | Add / remove windows in master |
| `M-v` / `M-S-f` | Unfloat window |
| `Print` | Screenshot to clipboard |
| `S-Print` | Screenshot to `~/Screenshots/` |
| `M-s` | Region screenshot to clipboard |
| `M-S-s` | Region screenshot to `~/Screenshots/` |
| `C-Print` | Active window screenshot to clipboard |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume -5% |
| `XF86AudioMute` | Mute toggle |
| `XF86AudioMicMute` | Mic mute toggle |
| `XF86AudioPlay` | Play/pause |
| `XF86AudioStop` | Stop |
| `XF86AudioPrev` / `Next` | Previous / next track |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness -5% |

`M` is `mod4Mask` (Super). Volume and brightness keys also write to `/tmp/xob-vol` so the overlay bar updates. That took longer to get working than I'd like to admit.

## Notes
- The bar is [Quickshell](https://quickshell.outfoxxed.me/). Launched via `spawnOnce` in the startup hook. Lives in `~/.xmonad/Bar/`.
- `exclusiveZone` in the Quickshell config does nothing on X11. Bar padding is handled by `spacingRaw` in xmonad. Don't be fooled.
- The network widget hardcodes `wlan0`. Wrong interface name? Update `NetworkWidget.qml`. Three occurrences. Don't miss one or you'll spend an entire afternoon wondering why nothing works. I speak from experience and a place of great personal suffering.
- Battery is detected at `BAT0` with fallback to `BAT1`. Check `ls /sys/class/power_supply/` if yours differs.
- `quickshell` is set to `doLower` in the window rules so it sits behind everything. This is correct behaviour. Don't touch it.
- Touchpad natural scrolling requires `/etc/X11/xorg.conf.d/30-touchpad.conf`. Not included. It's a system file. Symlinking system files is a chaos I've chosen not to inflict on anyone, least of all myself.

## Why XMonad
It's written in Haskell. The configuration *is* the program. It compiles or it doesn't. There's no ambiguity, no hidden state, no middle-management reinterpreting your requirements before implementing them incorrectly.

I find that refreshing.

---
*If something's broken, open an issue. I'm not at home. I don't have time.*
