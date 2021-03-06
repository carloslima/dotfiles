{-# LANGUAGE OverloadedStrings #-}

import Codec.Binary.UTF8.String
import qualified Codec.Binary.UTF8.String as UTF8
import Data.Monoid
import qualified DBus as D
import qualified DBus.Client as D
import XMonad
import XMonad.Actions.GridSelect
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.ToggleLayouts
import XMonad.Prompt
import XMonad.Prompt.Window
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

import XMonad.Config.Desktop
import XMonad.Util.Run (safeSpawn)

import qualified Data.Map as M

import System.Environment (getEnvironment)
gnomeConfig = desktopConfig
    { terminal = "gnome-terminal"
    , keys     = gnomeKeys <+> keys desktopConfig
    , startupHook = gnomeRegister >> startupHook desktopConfig }

gnomeKeys (XConfig {modMask = modm}) = M.fromList $
    [ ((modm, xK_p), gnomeRun)
    , ((modm .|. shiftMask, xK_q), spawn "gnome-session-save --kill") ]

gnomeRun :: X ()
gnomeRun = withDisplay $ \dpy -> do
    rw <- asks theRoot
    gnome_panel <- getAtom "_GNOME_PANEL_ACTION"
    panel_run   <- getAtom "_GNOME_PANEL_ACTION_RUN_DIALOG"

    io $ allocaXEvent $ \e -> do
        setEventType e clientMessage
        setClientMessageEvent e rw gnome_panel 32 panel_run 0
        sendEvent dpy rw False structureNotifyMask e
        sync dpy False

gnomeRegister :: MonadIO m => m ()
gnomeRegister = io $ do
    x <- lookup "DESKTOP_AUTOSTART_ID" `fmap` getEnvironment
    whenJust x $ \sessionId -> safeSpawn "dbus-send"
            ["--session"
            ,"--print-reply=literal"
            ,"--dest=org.gnome.SessionManager"
            ,"/org/gnome/SessionManager"
            ,"org.gnome.SessionManager.RegisterClient"
            ,"string:xmonad"
            ,"string:"++sessionId]
--

main :: IO ()
main = do
    dbus <- D.connectSession
    getWellKnownName dbus
    xmonad $ ewmh gnomeConfig
         { modMask = mod4Mask
         , borderWidth = 2
         , terminal = "gnome-terminal"
         , layoutHook = smartBorders $ toggleLayouts Full $ layoutHook gnomeConfig
         , workspaces = myWorkspaces
         , focusFollowsMouse = False
         , logHook = dynamicLogWithPP (prettyPrinter dbus)
         , handleEventHook = fullscreenEventHook
         , manageHook = composeAll
             [ manageHook gnomeConfig
             , title =? "Whisker Menu" --> doRectFloat  (W.RationalRect 0.0 0.0 0.4 0.95)
             , isFullscreen --> doFullFloat
             , isDialog --> doCenterFloat
             -- , title =? "VLC (XVideo output)" --> doFullFloat
             -- , title =? "Contact List" --> doFullFloat
             -- , className =? "Gcalctool" --> doCenterFloat
             -- , (className =? "Pidgin" <&&> title =? "Buddy List") --> doFloat
             , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
             , className =? "Xfce4-notifyd" --> doF W.focusDown
             , title =? "Find in Files" --> doCenterFloat -- MD
             ]

         } `additionalKeysP` myKeys

fullFloatFocused =
    withFocused $ \f -> windows =<< appEndo `fmap` runQuery doFullFloat f


myWorkspaces = ["`","1","2","3","4","5","6","7","8","9","0","-","=","[","]","\\"]

myKeys =
    [
      ("M-x",    spawn "~/bin/display_fix")
    , ("M-z",    spawn "xflock4")
    , ("C-M1-l", spawn "xflock4")
    , ("C-M1-k", fullFloatFocused)
    , ("M-f", sendMessage (Toggle "Full"))

--    , ("<XF86MonBrightnessUp>",  spawn "xbacklight -inc 5")
--    , ("<XF86MonBrightnesDown>", spawn "xbacklight -dec 5")

    , ("<XF86AudioPlay",  spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
    , ("<XF86AudioPrev>", spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
    , ("<XF86AudioNext>", spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")

    , ("<XF86AudioMute>",        spawn "amixer set Master toggle")
    , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+")
    , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%-")

    -- MS Keyboard :/
    , ("M-<F1>", spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause")
    , ("M-<F2>", spawn "amixer set Master toggle")
    , ("M-<F3>", spawn "amixer set Master 5%-")
    , ("M-<F4>", spawn "amixer set Master 5%+")
    , ("M-S-<Page_Up>",   spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous")
    , ("M-S-<Page_Down>", spawn "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next")


    -- , ("M1-<Tab>", goToSelected defaultGSConfig)
    , ("M1-<Tab>", spawn "rofi -show window")
    , ("M-<F7>", windowPromptGoto  defaultXPConfig)
    , ("M-<F8>", windowPromptBring defaultXPConfig)
    , ("M-<F9>", windowPromptGoto  defaultXPConfig { autoComplete = Just 500000 } )
    ]
    ++
    [ (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "`1234567890-=[]\\"
         , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- W.greedyView / W.view
                                      , ("S-", windows . W.shift)]
    ]
    ++
    [ (otherModMasks ++ "M-" ++ [key], screenWorkspace screen >>= flip whenJust (windows . action))
        | (key, screen) <- zip "ui" [0,1]
        -- | (key, screen) <- zip "ui" [1,0]
        -- | (key, screen) <- zip "uio" [1,0,0]
        -- | (key, screen) <- zip "uio" [1,0,2]  -- sitting
        -- | (key, screen) <- zip "yuio" [1,0,1,2]  -- mixed mess :-)
        , (otherModMasks, action) <- [("", W.view), ("S-", W.shift)]]


prettyPrinter :: D.Client -> PP
prettyPrinter dbus = defaultPP
    { ppOutput   = dbusOutput dbus
    , ppTitle    = pangoSanitize
    , ppCurrent  = pangoColor "blue" . wrap "[" "]" . pangoSanitize
    , ppVisible  = pangoColor "green" . wrap "(" ")" . pangoSanitize
    , ppHidden   = const ""
    , ppUrgent   = pangoColor "red"
    , ppLayout   = const ""
    , ppSep      = " "
    }

getWellKnownName :: D.Client -> IO ()
getWellKnownName dbus = do
  D.requestName dbus (D.busName_ "org.xmonad.Log")
                [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  return ()
  
dbusOutput :: D.Client -> String -> IO ()
dbusOutput dbus str = do
    let signal = (D.signal "/org/xmonad/Log" "org.xmonad.Log" "Update") {
            D.signalBody = [D.toVariant ("<b>" ++ (UTF8.decodeString str) ++ "</b>")]
        }
    D.emit dbus signal

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
  where
    left  = "<span foreground=\"" ++ fg ++ "\">"
    right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
  where
    sanitize '>'  xs = "&gt;" ++ xs
    sanitize '<'  xs = "&lt;" ++ xs
    sanitize '\"' xs = "&quot;" ++ xs
    sanitize '&'  xs = "&amp;" ++ xs
    sanitize x    xs = x:xs

