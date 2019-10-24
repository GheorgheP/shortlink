module ShortLink.Types.Url
  ( toUrl
  , toString
  , isUrl
  , trim
  , Url
  ) where

import           Data.Text  as T
import           Text.Regex (matchRegex, mkRegex)

newtype Url =
  Url String

urlReg = mkRegex "^https?://(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]+\\.[a-zA-Z0-9]+[/|\\?]?.*$"

-- | Check if String is a valid url
--
isUrl :: String -> Bool
isUrl str =
  case matchRegex urlReg str of
    Nothing  -> False
    (Just _) -> True

-- | Trim url end
trim :: Url -> Url
trim = Url . T.unpack . dropWhileEnd (`elem` "?/") . T.strip . T.pack . toString

-- | Convert String to Url if string is a valid Url
--
toUrl :: String -> Maybe Url
toUrl s =
  if isUrl s
    then (Just . Url . T.unpack . T.strip . T.pack) s
    else Nothing

-- | Convert Url to String
--
toString :: Url -> String
toString (Url s) = s
