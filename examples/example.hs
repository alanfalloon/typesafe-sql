{-# LANGUAGE QuasiQuotes #-}
import Database.SQL.QQ

mkTable [$sql| CREATE TABLE IF NOT EXISTS users
                   ( uid INTEGER PRIMARY KEY ASC
                   , name STRING
                   , added DATETIME ) |]

mkTable [$sql| CREATE TABLE IF NOT EXISTS email
                   ( eid INTEGER PRIMARY KEY ASC
                   , address STRING
                   , user INTEGER REFERENCES users (id) ) |]

mkQuery "userEmailAddresses" [$sql| SELECT address
                                    FROM email, users
                                    WHERE user = uid
                                    AND name = ? |]

main :: IO ()
main = return ()
