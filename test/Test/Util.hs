{-# LANGUAGE RecordWildCards #-}

module Test.Util(
    matchY, matchN,
    simple,
    arity,
    substitute, substituteErr,
    TestData(..), unsafeTestData,
    ) where

import Control.Exception.Extra
import Control.Monad.Extra
import Data.List.Extra
import Data.IORef
import System.FilePattern(FilePattern)
import qualified System.FilePattern as FP
import System.IO.Unsafe


---------------------------------------------------------------------
-- COLLECT TEST DATA

data TestData = TestData
    {testDataCases :: {-# UNPACK #-} !Int
    ,testDataPats :: [FilePattern]
    ,testDataPaths :: [FilePath]
    }

{-# NOINLINE testData #-}
testData :: IORef TestData
testData = unsafePerformIO $ newIORef $ TestData 0 [] []

addTestData :: [FilePattern] -> [FilePath] -> IO ()
addTestData pats paths = atomicModifyIORef' testData $ \t -> (f t, ())
    where f TestData{..} = TestData (testDataCases+1) (reverse pats ++ testDataPats) (reverse paths ++ testDataPaths)

unsafeTestData :: IO TestData
unsafeTestData = atomicModifyIORef' testData $ \t -> (TestData 0 [] [], f t)
    where f TestData{..} = TestData testDataCases (nubSort $ reverse testDataPats) (nubSort $ reverse testDataPaths)


---------------------------------------------------------------------
-- TEST UTILITIES

assertBool :: Partial => Bool -> String -> [String] -> IO ()
assertBool b msg fields = unless b $ error $ unlines $
    ("ASSERTION FAILED: " ++ msg) : fields

assertException :: (Show a, Partial) => IO a -> [String] -> String -> [String] -> IO ()
assertException a parts msg fields = do
    res <- try_ $ evaluate . length . show =<< a
    case res of
        Left e -> assertBool (all (`isInfixOf` show e) parts) msg $ ["Expected" #= parts, "Got" #= e] ++ fields
        Right _ -> assertBool False msg $ ["Expected" #= parts, "Got" #= "<No exception>"] ++ fields

(#=) :: Show a => String -> a -> String
(#=) a b = a ++ ": " ++ show b


---------------------------------------------------------------------
-- TEST WRAPPERS

match :: Partial => FilePattern -> FilePath -> Maybe [String] -> IO ()
match pat path want = do
    addTestData [pat] [path]
    let got = FP.match pat path
    assertBool (want == got) "match" ["Pattern" #= pat, "Path" #= path, "Expected" #= want, "Got" #= got]

matchY :: Partial => FilePattern -> FilePath -> [String] -> IO ()
matchY pat path xs = match pat path $ Just xs

matchN :: Partial => FilePattern -> FilePath -> IO ()
matchN pat path = match pat path Nothing


simple :: Partial => FilePattern -> Bool -> IO ()
simple pat want = do
    addTestData [pat] []
    let got = FP.simple pat
    assertBool (want == got) "simple" ["Pattern" #= pat, "Expected" #= want, "Got" #= got]

arity :: Partial => FilePattern -> Int -> IO ()
arity pat want = do
    addTestData [pat] []
    let got = FP.arity pat
    assertBool (want == got) "arity" ["Pattern" #= pat, "Expected" #= want, "Got" #= got]

substitute :: Partial => FilePattern -> [String] -> FilePath -> IO ()
substitute pat parts want = do
    addTestData [pat] [want]
    let got = FP.substitute pat parts
    assertBool (want == got) "substitute" ["Pattern" #= pat, "Parts" #= parts, "Expected" #= want, "Got" #= got]

substituteErr :: Partial => FilePattern -> [String] -> [String] -> IO ()
substituteErr pat parts want = do
    addTestData [pat] []
    assertException (return $ FP.substitute pat parts) want "substitute" ["Pattern" #= pat, "Parts" #= parts]