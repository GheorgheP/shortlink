module Url
  ( isUrl
  , trim
  , toUrl
  ) where

import           Data.Text  as T
import           Text.Regex (matchRegex, mkRegex)

urlReg = mkRegex "^https?://(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]+\\.[a-zA-Z0-9]+[/|\\?]?.*$"

isUrl :: String -> Bool
isUrl str =
  case matchRegex urlReg str of
    Nothing  -> False
    (Just _) -> True

toUrl :: String -> Maybe String
toUrl s =
  if isUrl s
    then Just $ trim s
    else Nothing

trim :: String -> String
trim = T.unpack . dropWhileEnd (`elem` "?/") . T.strip . T.pack
