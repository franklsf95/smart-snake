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
    let
        subArray = case Array.get i array of
            Nothing -> Debug.crash "index of out bound"
            Just arr -> arr
        subArray' = Array.set j x subArray
        array' = Array.set i subArray' array
    in
        array'
