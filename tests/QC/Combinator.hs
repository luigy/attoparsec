module QC.Combinator where

import Control.Applicative
import Data.Word (Word8)
import QC.Common (Repack, parseBS, repackBS)
import Test.Framework (Test)
import Test.Framework.Providers.QuickCheck2 (testProperty)
import Test.QuickCheck
import qualified Data.Attoparsec.ByteString.Char8 as P
import qualified Data.Attoparsec.Combinator as C
import qualified Data.ByteString as B

choice :: NonEmptyList (NonEmptyList Word8) -> Gen Property
choice (NonEmpty xs) = do
  let ys = map (B.pack . getNonEmpty) xs
  return . forAll (repackBS <$> arbitrary <*> elements ys) $
    maybe False (`elem` ys) . parseBS (C.choice (map P.string ys))

count :: Positive (Small Int) -> Repack -> B.ByteString -> Bool
count (Positive (Small n)) rs s =
    (length <$> parseBS (C.count n (P.string s)) input) == Just n
  where input = repackBS rs (B.concat (replicate (n+1) s))

tests :: [Test]
tests = [
    testProperty "choice" choice
  , testProperty "count" count
  ]