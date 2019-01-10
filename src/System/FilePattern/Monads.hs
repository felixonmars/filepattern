{-# LANGUAGE ViewPatterns, DeriveFunctor, LambdaCase #-}

-- | Some useful Monads
module System.FilePattern.Monads(
    Next, runNext, noNext, getNext,
    Out, addOut, runOut,
    ) where


-- | Next is a monad which has a series of elements, and can pull off the next one
newtype Next e a = Next ([e] -> Maybe ([e], a))
    deriving Functor

instance Applicative (Next e) where
    pure a = Next $ \es -> Just (es, a)
    Next f <*> Next x = Next $ \es -> do
        (es, f) <- f es
        (es, x) <- x es
        Just (es, f x)

noNext :: Next e a
noNext = Next $ const Nothing

getNext :: Next e e
getNext = Next $ \case
    e:es -> Just (es, e)
    _ -> Nothing

runNext :: [e] -> Next e a -> Maybe ([e], a)
runNext ps (Next f) = f ps


data Out v a = Out ([v] -> [v]) a
    deriving Functor

instance Applicative (Out v) where
    pure = Out id
    Out v1 f <*> Out v2 x = Out (v1 . v2) $ f x

addOut :: v -> Out v ()
addOut v = Out (v:) ()

runOut :: Out v a -> ([v], a)
runOut (Out v a) = (v [], a)
