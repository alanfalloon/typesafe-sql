
|
Module      :  Database.SQL.QQ
Copyright   :  (c) 2011 Alan Falloon
License     :  LGPL 2.1
Maintainer  :  alan.falloon@gmail.com
Stability   :  experimental
Portability :  non-portable

This library allows you to write SQL in-line in your Haskell
program. The SQL is parsed at compile time using template haskell, and
then used to automatically generate functions and data-types that can
be used in your program.

> module Database.SQL.QQ
>     ( sql
>     , ParsedSQL()
>       -- * Declaration Functions
>     , mkQuery
>     , mkStatement
>     , mkTable
>     ) where

> import Language.Haskell.TH.Quote
> import Language.SQL.SQLite
> import qualified Language.Haskell.TH as TH

| This quasi-quoter can recognize any SQL statements recognized by
'readStatementList'.

The resulting expression is intended to be used with functions like
'mkTable', 'mkStatement' and 'mkQuery' to transform them into the
appropriate haskell declarations.

> sql :: QuasiQuoter
> sql = QuasiQuoter
>       { quoteDec = illegalContext "declarations"
>       , quoteExp = sqlStmt
>       , quotePat = illegalContext "a pattern"
>       , quoteType = illegalContext "a type"
>       }

Generate an appropriate error message when the quasi-quoter is used in
the wrong context.

> illegalContext :: String -> String -> TH.Q a
> illegalContext ctx _ = fail $ "SQL quasi-quotes cannot be used as " ++ ctx

> sqlStmt :: String -> TH.Q TH.Exp
> sqlStmt s = case readStatementList s of
>               Left err -> do
>                 TH.report True (show err)
>                 TH.global (TH.mkName "Prelude.undefined")
>               Right _ -> TH.listE [TH.stringE s]

| The extracted information from quasi-quoted SQL.

> type ParsedSQL = [String]

| Declare a table.

This expects a single @CREATE TABLE@ statement, and from that it
declares a record type that represents the columns of the table,
defines a function to create the table by running the specified
statement, and a generic insertion function.

The statement must not contain any parameters.

Any table that is used in parameterized statements or queries must be
defined using 'mkTable' so that the proper type information can be
extracted. You can create tables though 'mkStatement', but using those
tables in parameterized queries will cause a compile error.

> mkTable :: ParsedSQL -- ^ The quasi-quoted SQL from 'sql' 
>            -> TH.Q [TH.Dec]
> mkTable _ = return []

| Declare statements.

This allows any arbitrary SQL to be declared. Any SQL statements are
accepted, and -- like 'mkQuery' -- the parameters are extracted and
turned into function parameters of the appropriate type. However, --
unlike 'mkQuery' -- no return value is extracted.

> mkStatement :: String -- ^ The name of the declared function
>                -> ParsedSQL -- ^ The quasi-quoted SQL from 'sql' 
>                -> TH.Q [TH.Dec]
> mkStatement _ _ = return []

| Declare a query.

This expects a single SQL statement that returns results (such as
@SELECT@). Any parameters in the statement become function parameters
of the appropriate types, and the return type of the declared function
is derived from the results of the statement.

> mkQuery :: String -- ^ The name of the declared function
>         -> ParsedSQL -- ^ The quasi-quoted SQL from 'sql'
>         -> TH.Q [TH.Dec]
> mkQuery _ _ = return []

