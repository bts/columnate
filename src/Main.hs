{-# language DeriveGeneric     #-}
{-# language OverloadedStrings #-}

module Main where

import Data.Maybe (fromMaybe)
import Data.Text (Text)
import GHC.Generics (Generic)
import Options.Generic (ParseRecord)

import qualified Data.Text
import qualified Data.Text.IO
import qualified Options.Generic

data Options
  = Options
    { separator :: Maybe Char }
  deriving (Generic, Show)

instance ParseRecord Options where
  parseRecord = Options.Generic.parseRecordWithModifiers $
    Options.Generic.defaultModifiers
      { Options.Generic.shortNameModifier = Options.Generic.firstLetter
      }

defaultSep :: Char
defaultSep = '\t'

columnate :: Char -> [Text] -> [Text]
columnate sep =
  fmap (Data.Text.unwords . Data.Text.splitOn (Data.Text.singleton sep))

-- TODO: add some basic tests for columnate function
-- TODO: right-pad each col to meet width of that column
-- TODO: add test/support for missing/extra cols

main :: IO ()
main = do
  Options mSep <- Options.Generic.getRecord "Columnate data sets while preserving color codes"
  let sep = fromMaybe defaultSep mSep
  Data.Text.IO.interact $ Data.Text.unlines . columnate sep . Data.Text.lines
