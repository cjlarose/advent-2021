{-# LANGUAGE OverloadedStrings #-}

module Advent.Parse
  ( Parser
  , parse
  ) where

import Text.Megaparsec (Parsec, errorBundlePretty)
import qualified Text.Megaparsec as Megaparsec
import Data.Void (Void)
import Data.Text (Text)

import Advent.PuzzleAnswerPair (PuzzleAnswerPair)

type Parser = Parsec Void Text

parse :: Parser a -> (a -> PuzzleAnswerPair) -> Text -> Either String PuzzleAnswerPair
parse p f x = either (Left . errorBundlePretty) (Right . f) $ Megaparsec.parse p "" x
