module Env
  ( getEnvNum
  , getEnvStr
  ) where

import           Data.String        (IsString, fromString)
import           System.Environment (getEnv)

-- | Read environment variable and convert to overloaded string
--
getEnvStr :: IsString s => String -> IO s
getEnvStr = fmap fromString . getEnv

-- | Read environment variable and convert to Num
getEnvNum :: (Num a, Read a) => String -> IO a
getEnvNum = fmap read . getEnv
