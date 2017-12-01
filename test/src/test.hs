import Test.Tasty

main :: IO ()
main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [properties, unitTests]

--

properties :: TestTree
properties = testGroup "Properties"
  [ -- TODO
  ]

unitTests :: TestTree
unitTests = testGroup "Unit tests"
  [ -- TODO
  ]
