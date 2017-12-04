{-# language DeriveGeneric     #-}
{-# language OverloadedStrings #-}

module Columnate where

import Control.Monad ((<$!>))
import Data.Maybe (fromMaybe)
import Data.Semigroup (Max (Max), (<>))
import Data.Text (Text)
import GHC.Generics (Generic)
import Options.Generic (ParseField (..), ParseRecord)

import qualified Data.Align
import qualified Data.Foldable
import qualified Data.Semigroup
import qualified Data.Text
import qualified Data.Text.IO
import qualified Data.These
import qualified Options.Generic

data Options
  = Options
    { separator :: Maybe Separator }
  deriving (Generic, Show)

instance ParseRecord Options where
  parseRecord = Options.Generic.parseRecordWithModifiers $
    Options.Generic.defaultModifiers
      { Options.Generic.shortNameModifier = Options.Generic.firstLetter
      }

newtype Separator = Sep { sepChar :: Char }
  deriving (Show)

instance ParseField Separator where
  parseField msg label shortName = Sep <$> parseField msg label shortName

--
-- TODO: use these:
--
newtype Line = Line Text
newtype Field = Field Text
type Fields = [Field]

defaultSep :: Separator -- TODO: use Data.Default
defaultSep = Sep '\t'

columnate :: Separator -> [Text] -> [Text]
columnate sep lines' = fmap Data.Text.unwords table
  where
    table :: [[Text]]
    table = Data.Text.splitOn (Data.Text.singleton $ sepChar sep) <$> lines'

    columnWidths :: [Int]
    columnWidths =
        Data.Semigroup.getMax <$!> Data.Foldable.foldl' updateWidths [] table
      where
        updateWidths :: [Max Int] -> [Text] -> [Max Int]
        updateWidths prevWidths fields = Data.These.mergeThese (<>) <$>
          Data.Align.align prevWidths (Max . Data.Text.length <$> fields)

    -- paddedTable :: [[Text]]
    -- paddedTable =

main :: IO ()
main = do
  Options mSep <- Options.Generic.getRecord
    "Columnate data sets while preserving color codes"
  let sep = fromMaybe defaultSep mSep
  Data.Text.IO.interact $ Data.Text.unlines . columnate sep . Data.Text.lines
