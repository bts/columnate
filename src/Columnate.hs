{-# language DeriveGeneric     #-}
{-# language OverloadedStrings #-}

module Columnate where

import Control.Applicative ((<|>))
import Control.Monad ((<$!>))
import Data.Maybe (fromMaybe)
import Data.Semigroup (Max (Max), (<>))
import Data.Text (Text)
import Data.These (These)
import GHC.Generics (Generic)
import Options.Generic (ParseField (..), ParseRecord)

import qualified Data.Align
import qualified Data.Attoparsec.Text
import qualified Data.Char
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
  deriving (Read, Show)

instance ParseField Separator where
  parseField msg label shortName = Sep <$> parseField msg label shortName

newtype Line = Line { lineText :: Text }
  deriving (Eq, Show)

newtype Field = Field { fieldText :: Text }

consumeColorCodeP :: Data.Attoparsec.Text.Parser ()
consumeColorCodeP = "\x1B["
  *> (Data.Attoparsec.Text.skipWhile Data.Char.isDigit
       `Data.Attoparsec.Text.sepBy1`
       Data.Attoparsec.Text.char ';')
  *> Data.Attoparsec.Text.skip (== 'm')

colorlessTextP :: Data.Attoparsec.Text.Parser Text
colorlessTextP = do
  before <- Data.Attoparsec.Text.takeWhile1 (/= '\x1B') <|> ""
  mNextChar <- Data.Attoparsec.Text.peekChar
  case mNextChar of
    Just _escapeChar -> do
      at <- (consumeColorCodeP *> "") <|> "\x1B"
      rest <- colorlessTextP
      pure $ before <> at <> rest
    Nothing -> pure before

colorless :: Text -> Text
colorless input =
  case Data.Attoparsec.Text.parseOnly parser input of
    Left err -> error $ "impossible: colorless parsing failed: " ++ err
    Right t  -> t

  where
    parser = colorlessTextP <* Data.Attoparsec.Text.endOfInput

fieldWidth :: Field -> Int
fieldWidth = Data.Text.length . colorless . fieldText

defaultSep :: Separator -- TODO: use Data.Default
defaultSep = Sep '\t'

--
-- TODO: we /could/ drop trailing spaces, but then we'd violate
-- prop_onlyLongerLines
--
columnate :: Separator -> [Line] -> [Line]
columnate sep lines' = collateFields . padFields <$> table
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

    padFields :: [Field] -> [Field]
    padFields fields = pad <$> Data.Align.align fields columnWidths
      where
        pad :: These Field Int -> Field
        pad = Data.These.these
          (\_field ->
            error "impossible: missing field width")
          (\width ->
            Field $ Data.Text.replicate width " ")
          (\field width ->
            Field $ fieldText field
                 <> Data.Text.replicate (width - fieldWidth field) " ")

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
