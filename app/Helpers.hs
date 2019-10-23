module Helpers
  ( readPort
  ) where

readPort :: (Num a, Read a) => String -> IO a
readPort = return . read
