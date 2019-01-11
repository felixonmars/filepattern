
module Test.Cases(testCases) where

import qualified Test.Util as T
import System.FilePath((</>))
import System.Info.Extra


testCases :: IO ()
testCases = testMatch >> testSimple >> testArity >> testSubstitute


testSimple :: IO ()
testSimple = do
    T.simple "a*b" False
    T.simple "a//b" True
    T.simple "a/**/b" False
    T.simple "/a/b/cccc_" True
    T.simple "a///b" True
    T.simple "a/**/b" False


testArity :: IO ()
testArity = do
    T.arity "" 0
    T.arity "foo/**/*" 2
    T.arity "//*a.txt" 1
    T.arity "foo//a*.txt" 1
    T.arity "**/*a.txt" 2
    T.arity "foo/**/a*.txt" 2
    T.arity "//*a.txt" 1
    T.arity "foo//a*.*txt" 2
    T.arity "foo/**/a*.*txt" 3


testSubstitute :: IO ()
testSubstitute = do
    T.substitute "**/*a*.txt" ["","test","da"] "testada.txt"
    T.substitute "**/*a.txt" ["foo/bar","test"] "foo/bar/testa.txt"
    -- error if the number of replacements is wrong
    T.substituteErr "nothing" ["test"] ["substitute","nothing","expects 0","got 1","test"]
    T.substituteErr "*/*" ["test"] ["substitute","*/*","expects 2","got 1","test"]


testMatch :: IO ()
testMatch = do
    T.matchN "//*.c" "foo/bar/baz.c"
    --T.matchY "//*.c" "/baz.c" ["baz"]
    T.matchY "**/*.c" "foo/bar/baz.c" ["foo/bar","baz"]
    T.matchY ("**" </> "*.c") ("foo/bar" </> "baz.c") ["foo/bar","baz"]
    T.matchY "*.c" "baz.c" ["baz"]
    T.matchN "//*.c" "baz.c"
    T.matchY "**/*.c" "baz.c" ["","baz"]
    T.matchY "**/*a.txt" "foo/bar/testa.txt" ["foo/bar","test"]
    T.matchN "**/*.c" "baz.txt"
    T.matchY "**/*a.txt" "testa.txt" ["","test"]
    T.matchY "**/a.txt" "a.txt" [""]
    T.matchY "a/**/b" "a/b" [""]
    T.matchY "a/**/b" "a/x/b" ["x"]
    T.matchY "a/**/b" "a/x/y/b" ["x/y"]
    T.matchY "a/**/**/b" "a/x/y/b" ["","x/y"]
    T.matchY "**/*a*.txt" "testada.txt" ["","test","da"]
    T.matchY "test.c" "test.c" []
    T.matchN "*.c" "foor/bar.c"
    T.matchN "*/*.c" "foo/bar/baz.c"
    T.matchN "foo//bar" "foobar"
    T.matchN "foo/**/bar" "foobar"
    T.matchN "foo//bar" "foobar/bar"
    T.matchN "foo/**/bar" "foobar/bar"
    T.matchN "foo//bar" "foo/foobar"
    T.matchN "foo/**/bar" "foo/foobar"
    -- T.matchY "foo//bar" "foo/bar" []
    T.matchY "foo/**/bar" "foo/bar" [""]
    T.matchY "foo/bar" ("foo" </> "bar") []
    T.matchY ("foo" </> "bar") "foo/bar" []
    T.matchY ("foo" </> "bar") ("foo" </> "bar") []
    T.matchY "**/*.c" ("bar" </> "baz" </> "foo.c") ["bar/baz","foo"]
    -- T.matchY "//*" "/bar" ["bar"]
    T.matchY "**/*" "/bar" ["/","bar"]
    T.matchN "/bob//foo" "/bob/this/test/foo"
    -- T.matchY "/bob//foo" "/bob/foo" []
    T.matchY "/bob/**/foo" "/bob/this/test/foo" ["this/test"]
    T.matchN "/bob//foo" "bob/this/test/foo"
    T.matchN "/bob/**/foo" "bob/this/test/foo"
    T.matchN "bob//foo/" "bob/this/test/foo/"
    -- T.matchY "bob//foo/" "bob/foo/" []
    T.matchY "bob/**/foo/" "bob/this/test/foo/" ["this/test"]
    T.matchY "bob/**/foo/" "bob/foo/" [""]
    T.matchY "bob/**/foo/" "bob//foo/" ["/"]
    T.matchN "bob//foo/" "bob/this/test/foo"
    T.matchN "bob/**/foo/" "bob/this/test/foo"
    T.matchY ("**" </> "*a*.txt") "testada.txt" ["","test","da"]
    T.matchN "a//" "a"
    T.matchY "a/**" "a" [""]
    -- T.matchY "a//" "a/" []
    T.matchN "/a//" "/a"
    T.matchY "a/**" "a" [""]
    -- T.matchY "/a//" "/a/" []
    T.matchY "/a/**" "/a" [""]
    T.matchN "///a//" "/a"
    -- T.matchY "///a//" "/a/" []
    T.matchY "**/a/**" "/a" ["/",""]
    T.matchN "///" ""
    -- T.matchY "///" "/" []
    T.matchY "/**" "/" ["/"]
    T.matchY "**/" "a/" ["a"]
    -- T.matchY "////" "/" []
    -- T.matchY "**/**" "" ["","/"]
    T.matchY "x/**/y" "x/y" [""]
    -- T.matchY "x///" "x/" []
    T.matchY "x/**/" "x/" [""]
    T.matchY "x/**/" "x/foo/" ["foo"]
    T.matchN "x///" "x"
    T.matchN "x/**/" "x"
    T.matchY "x/**/" "x/foo/bar/" ["foo/bar"]
    T.matchN "x///" "x/foo/bar"
    T.matchN "x/**/" "x/foo/bar"
    -- T.matchY "x///y" "x/y" []
    T.matchY "x/**/*/y" "x/z/y" ["","z"]
    T.matchY "" "" []
    T.matchN "" "y"
    T.matchN "" "/"

    T.matchY "*/*" "x/y" ["x","y"]
    T.matchN "*/*" "x"
    -- T.matchY "//*" "/x" ["x"]
    T.matchY "**/*" "x" ["","x"]
    -- T.matchY "//*" "/" [""]
    -- T.matchY "**/*" "" ["",""]
    -- T.matchY "*//" "x/" ["x"]
    T.matchY "*/**" "x" ["x",""]
    -- T.matchY "*//" "/" [""]
    -- T.matchY "*//*" "x/y" ["x","y"]
    T.matchY "*/**/*" "x/y" ["x","","y"]
    T.matchN "*//*" ""
    T.matchN "*/**/*" ""
    T.matchN "*//*" "x"
    T.matchN "*/**/*" "x"
    T.matchN "*//*//*" "x/y"
    T.matchN "*/**/*/**/*" "x/y"
    -- T.matchY "//*/" "//" [""]
    T.matchY "**/*/" "/" ["",""]
    -- T.matchY "*/////" "/" [""]
    T.matchY "*/**/**/" "/" ["","",""]
    T.matchN "b*b*b*//" "bb"
    T.matchN "b*b*b*/**" "bb"

    T.matchY "**" "/" ["//"] -- UGLY corner case
    T.matchY "**/x" "/x" ["/"]
    T.matchY "**" "x/" ["x/"]
    let s = if isWindows then '/' else '\\'
    T.matchY "**" "\\\\drive" [s:s:"drive"]
    T.matchY "**" "C:\\drive" ["C:"++s:"drive"]
    T.matchY "**" "C:drive" ["C:drive"]

    -- We support ignoring '.' values in FilePath as they are inserted by @filepath@ a lot
    -- T.matchY "./file" "file" []
    T.matchN "/file" "file"
    -- T.matchY "foo/./bar" "foo/bar" []
    T.matchY "foo/./bar" "foo/./bar" []
    -- T.matchY "foo/./bar" "foo/bar" []


{-
testWalk :: Switch -> IO ()
testWalk Switch{..} = do
    let shw (a, b) = "(" ++ show a ++ "," ++ maybe "Nothing" ((++) "Just " . showWalk) b ++ ")"
    let both p w = assertBool (shw res == shw w) "walk" ["Pattern" #= p, "Expected" #= shw w, "Got" #= shw res]
            where res = walk p
    let walk_ = Walk undefined

    both ["*.xml"] (False, Just walk_)
    both ["//*.xml"] (False, Just $ WalkTo ([], [("",walk_)]))
    both ["**/*.xml"] (False, Just walk_)
    both ["foo//*.xml"] (False, Just $ WalkTo ([], [("foo",walk_)]))
    both ["foo/**/*.xml"] (False, Just $ WalkTo ([], [("foo",walk_)]))
    both ["foo/bar/*.xml"] (False, Just $ WalkTo ([], [("foo",WalkTo ([],[("bar",walk_)]))]))
    both ["a","b/c"] (False, Just $ WalkTo (["a"],[("b",WalkTo (["c"],[]))]))
    let (False, Just (Walk f)) = walk ["*/bar/*.xml"]
        shw2 (b, mw) = (b, maybe "" showWalk mw)
    assertBool (shw2 (f "foo") == shw2 (False, Just $ WalkTo ([],[("bar",walk_)]))) "walk inner" []
    both ["bar/*.xml","baz//*.c"] (False, Just $ WalkTo ([],[("bar",walk_),("baz",walk_)]))
    both ["bar/*.xml","baz/**/*.c"] (False, Just $ WalkTo ([],[("bar",walk_),("baz",walk_)]))
    both [] (False, Nothing)
    both [""] (True, Just $ WalkTo ([""], []))
    both ["//"] (False, Just $ WalkTo ([], [("",WalkTo ([""],[]))]))
    both ["**"] (True, Just walk_)
-}
