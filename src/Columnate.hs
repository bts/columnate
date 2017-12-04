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

newtype Line = Line { lineText :: Text }
  deriving (Eq, Show)

newtype Field = Field { fieldText :: Text }

fieldWidth :: Field -> Int
fieldWidth = Data.Text.length . fieldText

defaultSep :: Separator -- TODO: use Data.Default
defaultSep = Sep '\t'

columnate :: Separator -> [Line] -> [Line]
columnate sep lines' = collateFields <$> table
  where
    collateFields :: [Field] -> Line
    collateFields = Line . Data.Text.unwords . fmap fieldText

    splitLine :: Line -> [Field]
    splitLine = fmap Field
              . Data.Text.splitOn (Data.Text.singleton $ sepChar sep)
              . lineText

    table :: [[Field]]
    table = splitLine <$> lines'

    columnWidths :: [Int]
    columnWidths =
        Data.Semigroup.getMax <$!> Data.Foldable.foldl' updateWidths [] table
      where
        updateWidths :: [Max Int] -> [Field] -> [Max Int]
        updateWidths prevWidths fields = Data.These.mergeThese (<>) <$>
          Data.Align.align prevWidths (Max . fieldWidth <$> fields)

    -- paddedTable :: [[Text]]
    -- paddedTable =

main :: IO ()
main = do
    Options mSep <- Options.Generic.getRecord
      "Columnate data sets while preserving color codes"
    let sep = fromMaybe defaultSep mSep
    Data.Text.IO.interact $ joinLines . columnate sep . splitText

  where
    splitText :: Text -> [Line]
    splitText = fmap Line . Data.Text.lines

    joinLines :: [Line] -> Text
    joinLines = Data.Text.unlines . fmap lineText
