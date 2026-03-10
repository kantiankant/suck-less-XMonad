-- xmonad.hs
-- ~/.xmonad/xmonad.hs

import XMonad
import XMonad.Operations (restart)
import System.Process (callCommand)
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders
import XMonad.Layout.BinarySpacePartition
import XMonad.Actions.CycleWS
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, removeKeysP)
import qualified XMonad.StackSet as W
import Graphics.X11.ExtraTypes.XF86
import System.Exit

-- ============================================================
-- Variables
-- ============================================================

myTerminal           = "alacritty"
myModMask            = mod4Mask
myBorderWidth        = 2
myFocusedBorderColor = "#FFFFFF"
myNormalBorderColor  = "#333333"
myWorkspaces         = ["1","2","3","4","5","6","7","8","9"]

-- ============================================================
-- Layouts
-- ============================================================

mySpacing = spacingRaw False (Border 5 5 5 5) True (Border 5 5 5 5) True

myLayout = avoidStruts $ mySpacing emptyBSP
       ||| noBorders Full

-- ============================================================
-- Window Rules
-- ============================================================

myManageHook = composeAll
    [ className =? "Gimp"    --> doFloat
    , className =? "firefox" <&&> title =? "Picture-in-Picture" --> doFloat
    , className =? "quickshell" --> doLower
    , isFullscreen           --> doFullFloat
    ]

-- ============================================================
-- Startup
-- ============================================================

myStartupHook :: X ()
myStartupHook = do
    spawn "picom"
    spawn "xwallpaper --focus /home/kant/.config/niri/walls/wall2.JPEG"
    spawn "rm -f /tmp/xob-vol && mkfifo /tmp/xob-vol && { xob < /tmp/xob-vol & while true; do sleep 86400 > /tmp/xob-vol; done; }"

-- ============================================================
-- Keybindings
-- ============================================================

myKeys :: [(String, X ())]
myKeys =
    -- Programs
    [ ("M-q",           spawn myTerminal)
    , ("M-<Space>",     spawn "rofi -show drun")
    , ("M-<Return>",    spawn "firefox")
    , ("M-e",           spawn "alacritty -e yazi")

    -- Screenshots (clipboard)
    , ("M-s",           spawn "maim -s | xclip -selection clipboard -t image/png")
    , ("<Print>",       spawn "maim | xclip -selection clipboard -t image/png")
    , ("C-<Print>",     spawn "maim --window $(xdotool getactivewindow) | xclip -selection clipboard -t image/png")

    -- Screenshots (file)
    , ("M-S-s",         spawn "maim -s ~/Screenshots/\"screenshot from $(date '+%Y-%m-%d %H:%M:%S').png\"")
    , ("S-<Print>",     spawn "maim ~/Screenshots/\"screenshot from $(date '+%Y-%m-%d %H:%M:%S').png\"")

    -- Volume
    , ("<XF86AudioRaiseVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1 > /tmp/xob-vol")
    , ("<XF86AudioLowerVolume>", spawn "pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1 > /tmp/xob-vol")
    , ("<XF86AudioMute>",        spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ("<XF86AudioMicMute>",     spawn "pactl set-source-mute @DEFAULT_SOURCE@ toggle")

    -- Media
    , ("<XF86AudioPlay>", spawn "playerctl play-pause")
    , ("<XF86AudioStop>", spawn "playerctl stop")
    , ("<XF86AudioPrev>", spawn "playerctl previous")
    , ("<XF86AudioNext>", spawn "playerctl next")

    -- Brightness
    , ("<XF86MonBrightnessUp>",   spawn "brightnessctl set +5% && brightnessctl get | awk -v max=$(brightnessctl max) '{printf \"%d\\n\", $1/max*100}' > /tmp/xob-vol")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 5%- && brightnessctl get | awk -v max=$(brightnessctl max) '{printf \"%d\\n\", $1/max*100}' > /tmp/xob-vol")

    -- Window management
    , ("M-w",   kill)
    , ("M-v",   withFocused $ windows . W.sink)
    , ("M-S-f", withFocused $ windows . W.sink)
    , ("M-S-e", io exitSuccess)
    , ("M-S-r", spawn "xmonad --recompile && xmonad --restart")

    -- Focus (hjkl)
    , ("M-h",   windows W.focusUp)
    , ("M-j",   windows W.focusDown)
    , ("M-k",   windows W.focusUp)
    , ("M-l",   windows W.focusDown)

    -- Move windows (shift+hjkl)
    , ("M-S-h", windows W.swapUp)
    , ("M-S-j", windows W.swapDown)
    , ("M-S-k", windows W.swapUp)
    , ("M-S-l", windows W.swapDown)

    -- Master area
    , ("M--",   sendMessage Shrink)
    , ("M-=",   sendMessage Expand)
    , ("M-i",   sendMessage (IncMasterN 1))
    , ("M-p",   sendMessage (IncMasterN (-1)))

    -- Layouts
    , ("M-f",   sendMessage NextLayout)
    , ("M-c",   sendMessage FirstLayout)
    , ("M-n",   sendMessage NextLayout)

    -- Workspaces
    , ("M-<Tab>", toggleWS)
    ]
    ++
    [ ("M-" ++ k,   windows $ W.greedyView w)
    | (k, w) <- zip (map show [1..9]) myWorkspaces
    ]
    ++
    [ ("M-S-" ++ k, windows (\s -> W.greedyView w $ W.shift w s))
    | (k, w) <- zip (map show [1..9]) myWorkspaces
    ]

-- ============================================================
-- Main
-- ============================================================

main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . docks
     $ def
        { terminal           = myTerminal
        , modMask            = myModMask
        , borderWidth        = myBorderWidth
        , focusedBorderColor = myFocusedBorderColor
        , normalBorderColor  = myNormalBorderColor
        , workspaces         = myWorkspaces
        , layoutHook         = myLayout
        , manageHook         = manageDocks <+> myManageHook <+> manageHook def
        , startupHook        = myStartupHook <> spawnOnce "quickshell -p ~/.xmonad/Bar"
        }
        `removeKeysP`     [ "M-S-q", "M-S-c", "M-p" ]
        `additionalKeysP` myKeys
