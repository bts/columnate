import Columnate (Field (..), Line (..), Separator (..))
import Data.Foldable (for_)
import Hedgehog (MonadGen, Property, assert, forAll, property, (===))
import Test.Tasty
import Test.Tasty.Hedgehog (testProperty)

import qualified Columnate
import qualified Data.Text
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range

main :: IO ()
main = defaultMain $ testGroup "Tests" [properties, examples]

properties :: TestTree
properties = testGroup "Properties"
  [ testProperty "columnate is idempotent"
      prop_idempotence
  , testProperty "columnate never adds or removes lines"
      prop_preservesLineCount
  , testProperty "columnate only increases line lengths"
      prop_onlyLongerLines
  ]

examples :: TestTree
examples = testGroup "Unit tests"
  [ -- TODO
  ]

--

genField :: MonadGen m => Separator -> m Char -> m Field
genField sep genChar = Field <$>
    Gen.text (Range.linear 0 100) (Gen.filter (/= c) genChar)
  where
    c = sepChar sep

genLine :: MonadGen m => Separator -> m Char -> m Line
genLine sep genChar = mkLine <$> genFieldList
  where
    tSep = Data.Text.singleton (sepChar sep)
    mkLine = Line . Data.Text.intercalate tSep . fmap fieldText
    genFieldList = Gen.list (Range.linear 0 20) (genField sep genChar)

genLines :: MonadGen m => Separator -> m Char -> m [Line]
genLines sep genChar = Gen.list (Range.linear 0 50) (genLine sep genChar)

prop_idempotence :: Property
prop_idempotence = property $ do
  let sep = Sep '\t'
      f = Columnate.columnate sep
  lines' <- forAll $ genLines sep Gen.unicode
  f lines' === f (f lines')

prop_preservesLineCount :: Property
prop_preservesLineCount = property $ do
  let sep = Sep '\t'
  lines' <- forAll $ genLines sep Gen.unicode
  length lines' === length (Columnate.columnate sep lines')

prop_onlyLongerLines :: Property
prop_onlyLongerLines = property $ do
    let sep = Sep '\t'
    before <- forAll $ genLines sep Gen.unicode
    let after = Columnate.columnate sep before
    for_ (zip before after) $ \(beforeLine, afterLine) ->
      assert $ lineLength beforeLine <= lineLength afterLine

  where
    lineLength :: Line -> Int
    lineLength = Data.Text.length . lineText
