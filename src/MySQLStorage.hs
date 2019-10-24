module MySQLStorage
  ( connect
  , ConnectionInfo(..)
  ) where

import           Data.ByteString           (ByteString)
import           Data.String               (fromString)
import           Data.Text                 (pack, unpack)
import qualified Database.MySQL.Base       as MSQL
import           Network.Socket            (HostName, PortNumber)
import qualified ShortLink.Classes.Storage as Classes
import qualified ShortLink.Types.Base      as Base
import qualified ShortLink.Types.Url       as URL
import           System.IO.Streams         (InputStream)
import qualified System.IO.Streams         as Streams

newtype Storage =
  Storage MSQL.MySQLConn

data ConnectionInfo =
  ConnectionInfo
    { host     :: HostName
    , port     :: PortNumber
    , dataBase :: ByteString
    , user     :: ByteString
    , password :: ByteString
    }

connect :: ConnectionInfo -> IO Storage
connect c = Storage <$> MSQL.connect (MSQL.ConnectInfo (host c) (port c) (dataBase c) (user c) (password c) 33)

mHead :: [a] -> Maybe a
mHead []    = Nothing
mHead (x:_) = Just x

insertQuery :: String
insertQuery = "INSERT INTO `links` (hash, url) VALUES (?, ?)"

byHashQuery :: String
byHashQuery = "SELECT url FROM `links` WHERE hash=? LIMIT 1"

toMySQLText :: String -> MSQL.MySQLValue
toMySQLText = MSQL.MySQLText . pack

textParam :: String -> MSQL.Param
textParam = MSQL.One . toMySQLText

textParams :: [String] -> MSQL.Param
textParams = MSQL.Many . map toMySQLText

unpackUrl :: MSQL.MySQLValue -> Maybe String
unpackUrl (MSQL.MySQLText v) = Just $ unpack v
unpackUrl _                  = Nothing

-- | Wrapper for MySQL.execute_
--
exec :: MSQL.QueryParam p => String -> [p] -> MSQL.MySQLConn -> IO MSQL.OK
exec queryS p conn = MSQL.execute conn (fromString queryS) p

-- | Wrapper for MySQL.query
--
query :: MSQL.QueryParam p => String -> [p] -> MSQL.MySQLConn -> IO ([MSQL.ColumnDef], InputStream [MSQL.MySQLValue])
query queryS params conn = MSQL.query conn (fromString queryS) params

instance Classes.Storage Storage
  -- | Get url from database by hash
  --
     where
  getUrl hash (Storage conn) =
    (URL.toUrl =<<) . (unpackUrl =<<) . (mHead =<<) <$>
    (Streams.read =<< snd <$> query byHashQuery [textParam hash] conn)
  -- | Insert new url in the database
  --
  addUrl hash url (Storage conn) = () <$ exec insertQuery [textParams [hash, URL.toString url]] conn
