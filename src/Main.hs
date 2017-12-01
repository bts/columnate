{-# language OverloadedStrings #-}

module Main where

import Data.Text (Text)

import qualified Data.Text
import qualified Data.Text.IO

columnate :: [Text] -> [Text]
columnate = fmap (Data.Text.unwords . Data.Text.splitOn "»")

main :: IO ()
main = Data.Text.IO.interact $ Data.Text.unlines . columnate . Data.Text.lines
