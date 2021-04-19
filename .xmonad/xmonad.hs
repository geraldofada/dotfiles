-- Base
import XMonad
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

-- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WithAll (sinkAll, killAll)

-- Data
import Data.Maybe (fromJust)
import Data.Monoid
import qualified Data.Map as M

-- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docksEventHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode

-- Layouts
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed

-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.Magnifier
import XMonad.Layout.MultiToggle (mkToggle, single)
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowNavigation
import XMonad.Layout.WindowArranger (windowArrange)
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

   -- Utilities
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:JetBrains Mono:light:size=9:antialias=true:hinting=true"

myBG :: String
myBG = "#1c1e26"
myFG :: String
myFG = "#e0e0e0"
myYellow :: String
myYellow = "#fab795"
myBlack :: String
myBlack = "#16161c"

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBorderWidth :: Dimension
myBorderWidth = 1

myNormColor :: String
myNormColor   = myBG

myFocusColor :: String
myFocusColor  = myFG

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
        spawnOnce "picom --experimental-backends &"
        spawnOnce "${HOME}/.fehbg &"
        spawnOnce "udiskie --no-notify &"

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

tall = renamed [Replace "tall"] $
        mySpacing 5 $
        ResizableTall 1 (3/100) (1/2) []

magnify = renamed [Replace "magnify"] $
        mySpacing 5 $
        magnifier $
        ResizableTall 1 (3/100) (1/2) []

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def
        {
        fontName            = myFont,
        activeColor         = myBG,
        inactiveColor       = myBlack,
        activeBorderColor   = myBG,
        inactiveBorderColor = myBlack,
        activeTextColor     = myYellow,
        inactiveTextColor   = myFG
        }

-- The layout hook
myLayoutHook =
        windowNavigation $
        addTabs shrinkText myTabTheme $
        subLayout [] (Simplest) $
        limitWindows 12 $
        smartBorders $
        avoidStruts $
        mouseResize $
        windowArrange $
        T.toggleLayouts magnify $
        mkToggle (single NBFULL) tall ||| magnify

myWorkspaces = [" I ", " II ", " III ", " IV ", " V ", " VI ", " VII ", " VIII ", " IX "]
myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
        where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
        [
        -- float firefox dialogs
        (className =? "firefox" <&&> resource =? "Dialog") --> doFloat,
        (className =? "TelegramDesktop") --> doFloat
        ]

myKeys :: [(String, X ())]
myKeys =
        [
        -- recompile Xmonad
        ("M-C-r", spawn "xmonad --recompile"),
        -- restart Xmonad
        ("M-M1-r", spawn "xmonad --restart"),
        -- exit Xmonad
        ("M-S-q", io exitSuccess),

        -- launch terminal
        ("M-<Return>", spawn (myTerminal)),

        -- run rofi
        ("M-<Space>", spawn "rofi -show drun -display-drun \"Run:\""),
        -- show open windows
        ("M-u", spawn "rofi -show window -display-window \"Window:\""),

        -- lock screen
        ("M-M1-x", spawn "betterlockscreen -l blur -t \"Digite a senha...\""),

        -- print screen to clipbloard
        ("<Print>", spawn "maim -s -u -m 10 | xclip -selection clipboard -t image/png"),
        -- print the whole screen to clipboard
        ("M-<Print>", spawn "maim -u -m 10 | xclip -selection clipboard -t image/png"),
        -- print screen to clipboard and save it
        ("S-<Print>", spawn "maim -s -u -m 10 | tee ~/screenshots/\"$(date +%Y%m%d-%H%M%S).png\" | xclip -selection clipboard -t image/png"),
        -- print the whole screen to clipboard and save it
        ("M-S-<Print>", spawn "maim -u -m 10 | tee ~/screenshots/\"$(date +%Y%m%d-%H%M%S).png\" | xclip -selection clipboard -t image/png"),

        -- kill currently focused client
        ("M-w", kill1),
        -- kill all windows on current workspace
        ("M-S-w", killAll),

        -- toggles floats layout
        ("M-f", sendMessage $ T.Toggle "magnify"),
        -- push floating windows back to tile
        ("M-t", withFocused $ windows . W.sink),
        -- push all windows to tile
        ("M-S-t", sinkAll),

        -- move focus to the master window
        ("M-n", windows W.focusMaster),
        -- Move focus to the next window
        ("M-j", windows W.focusDown),
        -- Move focus to the prev window
        ("M-k", windows W.focusUp),
        -- Swap the focused window and the master window
        ("M-S-m", windows W.swapMaster),
        -- Swap focused window with next window
        ("M-S-j", windows W.swapDown),
        -- Swap focused window with prev window
        ("M-S-k", windows W.swapUp),
        -- Moves focused window to master, others maintain order
        ("M-<Backspace>", promote),
        -- Rotate all windows except master and keep focus in place
        ("M-S-<Tab>", rotSlavesDown),
        -- Rotate all the windows in the current stack
        ("M-C-<Tab>", rotAllDown),

        -- switch to next layout
        ("M-S-<Return>", sendMessage NextLayout),
        -- toggles noborder/full
        ("M-m", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts),

        -- Window resizing
        -- Shrink horiz window width
        ("M-h", sendMessage Shrink),
        -- Expand horiz window width
        ("M-l", sendMessage Expand),
        -- Shrink vert window width
        ("M-M1-j", sendMessage MirrorShrink),
        -- Exoand vert window width
        ("M-M1-k", sendMessage MirrorExpand),

        -- Sublayouts
        -- This is used to push windows to tabbed sublayouts, or pull them out of it.
        ("M-C-h", sendMessage $ pullGroup L),
        ("M-C-l", sendMessage $ pullGroup R),
        ("M-C-k", sendMessage $ pullGroup U),
        ("M-C-j", sendMessage $ pullGroup D),
        ("M-C-m", withFocused (sendMessage . MergeAll)),
        ("M-C-u", withFocused (sendMessage . UnMerge)),
        ("M-C-/", withFocused (sendMessage . UnMergeAll)),
        -- Switch focus to next tab
        ("M-C-.", onGroup W.focusUp'),
        -- Switch focus to prev tab
        ("M-C-,", onGroup W.focusDown')
        ]

main :: IO ()
main = do
        -- launch xmobar
        xmproc0 <- spawnPipe "xmobar -x 0 ${HOME}/.config/xmobar/xmobarrc"

        xmonad $ ewmh def
                {
                manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageDocks,
                -- Run xmonad commands from command line with "xmonadctl command". Commands include:
                -- shrink, expand, next-layout, default-layout, restart-wm, xterm, kill, refresh, run,
                -- focus-up, focus-down, swap-up, swap-down, swap-master, sink, quit-wm. You can run
                -- "xmonadctl 0" to generate full list of commands written to ~/.xsession-errors.
                -- To compile xmonadctl: ghc -dynamic xmonadctl.hs
                handleEventHook = serverModeEventHookCmd
                                <+> serverModeEventHook
                                <+> serverModeEventHookF "XMONAD_PRINT" (io . putStrLn)
                                <+> docksEventHook,
                                -- <+> fullscreenEventHook  -- this does NOT work right if using multi-monitors!
                modMask = myModMask,
                terminal = myTerminal,
                startupHook = myStartupHook,
                layoutHook = myLayoutHook,
                workspaces = myWorkspaces,
                borderWidth = myBorderWidth,
                normalBorderColor = myNormColor,
                focusedBorderColor = myFocusColor,
                focusFollowsMouse = False,
                logHook = dynamicLogWithPP $ xmobarPP
                        {
                        ppOutput = \x -> hPutStrLn xmproc0 x,
                        -- Current workspace in xmobar
                        ppCurrent = xmobarColor "#98be65" "" . wrap "[" "]",
                        -- Visible but not current workspace
                        ppVisible = xmobarColor "#98be65" "" . clickable,
                        -- Hidden workspaces in xmobar
                        ppHidden = xmobarColor "#82AAFF" "" . wrap "*" "" . clickable,
                        -- Hidden workspaces (no windows)
                        ppHiddenNoWindows = xmobarColor "#c792ea" ""  . clickable,
                        -- Title of active window in xmobar
                        ppTitle = xmobarColor "#b3afc2" "" . shorten 60,
                        -- Separators in xmobar
                        ppSep =  "<fc=#666666> <fn=1>|</fn> </fc>",
                        -- Urgent workspace
                        ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!",
                        -- # of windows current workspace
                        ppExtras  = [windowCount],
                        ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        }
                } `additionalKeysP` myKeys
