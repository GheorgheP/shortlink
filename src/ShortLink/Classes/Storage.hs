module ShortLink.Classes.Storage
  ( Storage
  , getUrl
  , addUrl
  ) where

import           ShortLink.Types.Base (Hash, Url)

class Storage a where
  getUrl :: Hash -> a -> IO (Maybe Url)
  addUrl :: Hash -> Url -> a -> IO ()
