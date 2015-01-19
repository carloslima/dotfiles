import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

import Codec.Binary.UTF8.String
import Data.Monoid
import XMonad.Actions.GridSelect
import XMonad.Prompt
import XMonad.Prompt.Window

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
    xmonad $ gnomeConfig
         { modMask = mod4Mask
         , borderWidth = 2
         , terminal = "gnome-terminal"
         , layoutHook = smartBorders $ layoutHook gnomeConfig
         , workspaces = myWorkspaces
         , focusFollowsMouse = False
         , manageHook = composeAll
             [ manageHook gnomeConfig
             -- , isFullscreen --> doFullFloat
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


myWorkspaces = ["`","1","2","3","4","5","6","7","8","9","0","-","="]

myKeys =
    [
      ("M-x",    spawn "~/bin/display_fix")
    , ("M-z",    spawn "xflock4")
    , ("C-M1-l", spawn "xflock4")

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


    , ("M1-<Tab>", goToSelected defaultGSConfig)
    , ("M-<F7>", windowPromptGoto  defaultXPConfig)
    , ("M-<F8>", windowPromptBring defaultXPConfig)
    , ("M-<F9>", windowPromptGoto  defaultXPConfig { autoComplete = Just 500000 } )
    ]
    ++
    [ (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "`1234567890-="
         , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- W.greedyView / W.view
                                      , ("S-", windows . W.shift)]
    ]
    ++
    [ (otherModMasks ++ "M-" ++ [key], screenWorkspace screen >>= flip whenJust (windows . action))
        | (key, screen) <- zip "uio" [2,1,0]  -- standing desk
        -- | (key, screen) <- zip "uio" [1,0,2]  -- sitting
        -- | (key, screen) <- zip "yuio" [1,0,1,2]  -- mixed mess :-)
        , (otherModMasks, action) <- [("", W.view), ("S-", W.shift)]]
