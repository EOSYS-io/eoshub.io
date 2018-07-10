module Action exposing (..)

import Round
import Json.Encode as JE


type alias TransferMsg =
    { from : String
    , to : String
    , quantity : String
    , memo : String
    }


type Action
    = Transfer TransferMsg


transferMsgToValue : TransferMsg -> JE.Value
transferMsgToValue { from, to, quantity, memo } =
    -- TODO(heejae): Use flags of Elm to keep constants.
    -- Also, introduce form validation.
    JE.object
        [ ( "account", JE.string "eosio.token" )
        , ( "action", JE.string "transfer" )
        , ( "payload"
          , JE.object
                [ ( "from", JE.string from )
                , ( "to", JE.string to )
                , ( "quantity", JE.string ((quantity |> (String.toFloat >> (Result.withDefault 0) >> (Round.round 4))) ++ (" EOS")) )
                , ( "memo", JE.string memo )
                ]
          )
        ]


encodeAction : Action -> JE.Value
encodeAction action =
    case action of
        Transfer msg ->
            transferMsgToValue msg
