{-# LANGUAGE OverloadedStrings #-}

module DB
  ( storage
  ) where

import           MySQLStorage

connData :: ConnectionInfo
connData = ConnectionInfo "127.0.0.1" 3400 "shortlink" "shortlink_user" "shortlink_pass"

storage = MySQLStorage.connect connData
