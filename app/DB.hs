{-# LANGUAGE OverloadedStrings #-}

module DB
  ( storage
  ) where

import           Data.String        (IsString, fromString)
import           Env                (getEnvNum, getEnvStr)
import           MySQLStorage
import           System.Environment (getEnv)

storage = do
  host <- getEnvStr "DB_HOST"
  port <- getEnvNum "DB_PORT"
  name <- getEnvStr "DB_NAME"
  user <- getEnvStr "DB_USER"
  pass <- getEnvStr "DB_PASSWORD"
  let connData = ConnectionInfo host port name user pass
  MySQLStorage.connect connData
