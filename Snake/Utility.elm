module Snake.Utility where

import List

unmaybe : (a -> Maybe b) -> String -> (a -> b)
unmaybe f crashMsg =
    \x ->
        case f x of
            Just t -> t
            Nothing -> Debug.crash crashMsg

head : List a -> a
head = unmaybe List.head "empty list"

tail : List a -> List a
tail = unmaybe List.tail "empty list"
