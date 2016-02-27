module Snake.Utility where

import Array exposing (Array)
import List

{- Maybe -}

unmaybe : String -> Maybe a -> a
unmaybe crashMsg mx =
    case mx of
        Nothing -> Debug.crash crashMsg
        Just x -> x

unmaybefy : String -> (a -> Maybe b) -> (a -> b)
unmaybefy crashMsg f = f >> unmaybe crashMsg

{- List -}

head : List a -> a
head = unmaybefy "empty list" List.head

tail : List a -> List a
tail = unmaybefy "empty list" List.tail

second : List a -> a
second l =
    case l of
        [_, x2] ->
            x2
        _ ->
            Debug.crash "second"

-- picks the n-th element from a list and return the rest
nthAndRest : Int -> List a -> (a, List a)
nthAndRest n xs =
    let
        before = List.take n xs
        after = List.drop n xs
        x = head after
        after' = tail after
    in
        (x, List.append before after')

maxBy : (a -> a -> Bool) -> List a -> Maybe a
maxBy gt xs =
    let
        f x sofar =
            case sofar of
                Nothing -> Just x
                Just y -> if gt x y then Just x else Just y
    in
        List.foldr f Nothing xs

{- Array -}

set : Int -> Int -> a -> Array (Array a) -> Array (Array a)
set i j x array =
    case Array.get i array of
        Nothing ->
            array  -- index out of bound
        Just subArray ->
            let
                subArray' = Array.set j x subArray
            in
                Array.set i subArray' array
