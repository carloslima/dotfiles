import XMonad
import XMonad.Config.Gnome
import XMonad.Actions.Submap
import XMonad.Actions.UpdatePointer
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

import Codec.Binary.UTF8.String
import Control.Arrow
import Control.OldException
import Data.Bits
import qualified Data.Map as M
import Data.Monoid

main :: IO ()
main = do
    xmonad $ gnomeConfig
         { modMask = mod4Mask
         , borderWidth = 2
         -- , terminal = "gnome-terminal"
         , layoutHook = smartBorders $ layoutHook gnomeConfig
         , workspaces = myWorkspaces
         , focusFollowsMouse = False
         , manageHook = composeAll
             [ manageHook gnomeConfig
             -- , isFullscreen --> doFullFloat
             , title =? "VLC (XVideo output)" --> doFullFloat
             -- , title =? "Contact List" --> doFullFloat
             , className =? "Gcalctool" --> doCenterFloat
             , (className =? "Pidgin" <&&> title =? "Buddy List") --> doFloat
             , className =? "Skype" --> doCenterFloat
             , (className =? "Gnome-panel" <&&> title =? "Run Application") --> doCenterFloat
             , title =? "Find in Files" --> doCenterFloat -- MD
             , title =? "NVIDIA X Server Settings" --> doCenterFloat
             ]
         } `additionalKeysP` myKeys

fullFloatFocused =
    withFocused $ \f -> windows =<< appEndo `fmap` runQuery doFullFloat f


myWorkspaces = ["`","1","2","3","4","5","6","7","8","9","0","-","="]

myKeys =
    [ (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "`1234567890-="
         , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- W.greedyView / W.view
                                      , ("S-", windows . W.shift)]
    ]
    ++
    [ (otherModMasks ++ "M-" ++ [key], screenWorkspace screen >>= flip whenJust (windows . action))
        | (key, screen) <- zip "uio" [0,1,2]  -- standing desk
        -- | (key, screen) <- zip "uio" [1,0,2]  -- sitting
        -- | (key, screen) <- zip "yuio" [1,0,1,2]  -- mixed mess :-)
        , (otherModMasks, action) <- [("", W.view), ("S-", W.shift)]]

