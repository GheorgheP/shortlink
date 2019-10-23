{-# LANGUAGE OverloadedStrings #-}

module DB
  ( storage
  ) where

import           Data.String        (fromString)
import           Helpers            (readPort)
import           MySQLStorage
import           System.Environment (getEnv)

storage = do
  host <- getEnv "DB_HOST"
  port <- readPort =<< getEnv "DB_PORT"
  name <- fromString <$> getEnv "DB_NAME"
  user <- fromString <$> getEnv "DB_USER"
  pass <- fromString <$> getEnv "DB_PASSWORD"
  let connData = ConnectionInfo host port name user pass
  MySQLStorage.connect connData
