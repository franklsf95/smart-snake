module Snake.Utility where

import Array exposing (Array)
import List

unmaybe : String -> Maybe a -> a
unmaybe crashMsg mx =
    case mx of
        Nothing -> Debug.crash crashMsg
        Just x -> x

unmaybefy : String -> (a -> Maybe b) -> (a -> b)
unmaybefy crashMsg f = f >> unmaybe crashMsg

head : List a -> a
head = unmaybefy "empty list" List.head

tail : List a -> List a
tail = unmaybefy "empty list" List.tail

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
