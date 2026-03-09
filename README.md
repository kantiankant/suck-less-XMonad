# suck-less-XMonad

My XMonad configuration. It works (in theory)

## What's in here

| Directory | What it does |
|-----------|-------------|
| `xmonad/` | The window manager config that started this whole mess |
| `alacritty/` | Terminal emulator. Fast. Doesn't crash. Unlike some employers I could name |
| `picom/` | Compositor. Makes things look nice. Purely cosmetic. I know the feeling |
| `nvim/` | Text editor config. Black and white colourscheme because I've given up on joy |
| `fastfetch/` | Tells you what computer you're on. Useful if you've forgotten. Or been asked to clear your desk |

## Dependencies

```
xmonad xmonad-contrib ghc alacritty rofi firefox yazi maim xclip
xdotool pactl playerctl brightnessctl wlogout picom xwallpaper xob quickshell xmessage
```

On Arch:

```bash
paru -S xmonad xmonad-contrib alacritty rofi firefox yazi maim xclip \
        xdotool playerctl brightnessctl wlogout picom xwallpaper xob quickshell xmessage
```

`xmonad` and `xmonad-contrib` are managed via Stack because the AUR versions lag behind and I've had quite enough of things lagging behind without my permission.

## Installation

```bash
git clone https://github.com/kantiankant/suck-less-XMonad ~/.config/suck-less-XMonad
```

Then symlink whatever you actually want:

```bash
ln -sf ~/.config/suck-less-XMonad/xmonad ~/.xmonad
ln -sf ~/.config/suck-less-XMonad/alacritty ~/.config/alacritty
ln -sf ~/.config/suck-less-XMonad/picom ~/.config/picom
ln -sf ~/.config/suck-less-XMonad/nvim ~/.config/nvim
```

Then build xmonad:

```bash
cd ~/.xmonad && xmonad --recompile
```

If it errors, read the error. If you can't read Haskell, that's not my problem. It's probably an indentation issue. It's always an indentation issue.

## Updating

There's a script for that:

```bash
xmonad-update
```

It updates Stack, fetches the latest xmonad and xmonad-contrib from Hackage, patches the stack.yaml, rebuilds, and insults you appropriately based on the outcome. If nothing needed updating it will tell you that too, in terms you won't enjoy.

Install it:

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
| `M-f` | Next layout |
| `M-Tab` | Toggle last workspace |
| `M-hjkl` | Focus windows |
| `M-S-hjkl` | Move windows |
| `Print` | Screenshot to clipboard |
| `S-Print` | Screenshot to `~/Screenshots/` |
| `M-s` | Region screenshot to clipboard |
| `M-S-s` | Region screenshot to `~/Screenshots/` |
| `C-Print` | Active window screenshot to clipboard |

## Notes

- Wallpaper path is hardcoded in `xmonad.hs`. Change it or it won't work. I hardcoded it because I know exactly where my wallpaper is, which is more than I can say about my career trajectory.
- The bar is [Quickshell](https://quickshell.outfoxxed.me/). It's in a separate directory because it has opinions about its own structure and I've learned to pick my battles.
- `exclusiveZone` in the Quickshell config does nothing on X11. Don't be fooled by it. The padding is handled by `spacingRaw` in xmonad directly.
- The neovim colourscheme is black and white. On purpose. Syntax highlighting is a crutch.

## Why XMonad

It's written in Haskell. The configuration *is* the program. It compiles or it doesn't. There's no ambiguity, no hidden state, no middle-management reinterpreting your requirements before implementing them incorrectly. 

I find that refreshing.

---

*If something's broken, open an issue. I'm not at home. I don't have time.*
