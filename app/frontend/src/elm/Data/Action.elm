module Data.Action exposing (Action)


type alias Action =
    { global_action_seq : Int
    , account_action_seq : Int
    }
