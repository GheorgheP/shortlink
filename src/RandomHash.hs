module RandomHash
  ( randHash
  ) where

import           Control.Monad (join)
import           GHC.Base      (IO)
import           System.Random (randomRIO)

values :: String
values = ['a' .. 'z'] ++ ['0' .. '9']

randIndex :: Int -> IO Int
randIndex n = randomRIO (0, n - 1)

randChar :: String -> IO Char
randChar values = (values !!) <$> randIndex (length values)

randHash :: Int -> IO String
randHash 0 = return ""
randHash n = do
  x <- randChar values
  xs <- randHash $ n - 1
  return (x : xs)
