{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Control.Exception         (SomeException, try)
import           Control.Monad             (join)
import           Control.Monad.IO.Class    (liftIO)
import           Data.Monoid               (mconcat)
import           Data.String
import           Data.Text.Lazy            (pack)
import qualified DB
import           Env                       (getEnvNum)
import           GHC.Exception             (Exception)
import           GHC.Exception.Type        (displayException)
import           Network.HTTP.Types        (status400, status404, status500)
import           RandomHash                (randHash)
import qualified ShortLink.Classes.Storage as S
import           Url                       (toUrl)
import qualified Web.Scotty                as S

main :: IO ()
main = do
  appPort <- getEnvNum "APP_PORT"
  conn <- DB.storage
  S.scotty appPort $ do
    S.get "/" $ S.html "<h1>Salutare</h1>"
    S.get "/api/url/:hash" $ do
      hash <- S.param "hash"
      handle showURL $ S.getUrl hash conn
    S.get "/api/add/:url" $ do
      url <- toUrl <$> S.param "url"
      case url of
        Nothing -> S.status status400 >> S.text "Invalid URL"
        (Just url) -> do
          hash <- liftIO getHash
          let shorten = S.text . pack . getUrl . const hash
          handle shorten $ S.addUrl hash url conn

hashLn :: Int
hashLn = 5

getHash :: IO String
getHash = randHash hashLn

host :: String
host = "http://localhost:3000/"

getUrl :: String -> String
getUrl = (host ++)

try' :: IO a -> IO (Either SomeException a)
try' = try

handle :: (a -> S.ActionM ()) -> IO a -> S.ActionM ()
handle f io = do
  r <- liftIO $ try' io
  case r of
    Left e  -> S.status status500 >> (S.text . pack . displayException) e
    Right a -> f a

showURL :: Maybe String -> S.ActionM ()
showURL (Just url) = S.text $ pack url
showURL _          = S.status status404 >> S.text "Not matching URL found"
