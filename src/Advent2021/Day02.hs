{-# LANGUAGE OverloadedStrings #-}

module Advent2021.Day02
  ( solve,
  )
where

import Advent.CommonParsers (linesOf, natural, symbol, token)
import Advent.Input (getProblemInputAsText)
import Advent.Parse (Parser, parse)
import Advent.PuzzleAnswerPair (PuzzleAnswerPair (..))
import Control.Monad (foldM)
import Control.Monad.Combinators (choice)
import Control.Monad.State (State, evalState, get, put, state)
import Data.List (foldl')
import Data.Text (Text)
import Numeric.Natural (Natural)
import Text.Megaparsec (eof, some, (<|>))

data Command = Forward Natural | Down Natural | Up Natural

inputParser :: Parser [Command]
inputParser = some command <* eof
  where
    commandP :: Text -> (Natural -> Command) -> Parser Command
    commandP literal f = symbol literal *> (f <$> token natural)

    command :: Parser Command
    command =
      choice
        [ commandP "forward" Forward,
          commandP "down" Down,
          commandP "up" Up
        ]

data Submarine = Submarine {horizontalPosition :: Int, depth :: Int}

type Aim = State Int

totalDisplacement :: [Command] -> Submarine
totalDisplacement = foldl' runSub (Submarine 0 0)
  where
    runSub :: Submarine -> Command -> Submarine
    runSub sub (Forward x) =
      sub {horizontalPosition = horizontalPosition sub + fromIntegral x}
    runSub sub (Down x) =
      sub {depth = depth sub + fromIntegral x}
    runSub sub (Up x) =
      sub {depth = depth sub - fromIntegral x}

totalDisplacementWithAim :: [Command] -> Submarine
totalDisplacementWithAim xs = evalState (foldM runSub (Submarine 0 0) xs) 0
  where
    runSub :: Submarine -> Command -> Aim Submarine
    runSub sub (Forward x) = do
      aim <- get
      let newPos = horizontalPosition sub + fromIntegral x
      let newDepth = depth sub + aim * fromIntegral x
      return $ Submarine newPos newDepth
    runSub sub (Down x) = state (\aim -> (sub, aim + fromIntegral x))
    runSub sub (Up x) = state (\aim -> (sub, aim - fromIntegral x))

printResults :: [Command] -> PuzzleAnswerPair
printResults depths = PuzzleAnswerPair (part1, part2)
  where
    Submarine pos depth = totalDisplacement depths
    part1 = show $ pos * depth
    Submarine pos' depth' = totalDisplacementWithAim depths
    part2 = show $ pos' * depth'

solve :: IO (Either String PuzzleAnswerPair)
solve = parse inputParser printResults <$> getProblemInputAsText 2
