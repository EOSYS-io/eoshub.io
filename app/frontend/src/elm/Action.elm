module Action exposing (TransferMessage, Action(..), transferMessageToValue, encodeAction)

import Json.Encode as JE
import Round


type alias TransferMessage =
    { from : String
    , to : String
    , quantity : String
    , memo : String
    }


type Action
    = Transfer TransferMessage


transferMessageToValue : TransferMessage -> JE.Value
transferMessageToValue { from, to, quantity, memo } =
    -- Introduce form validation.
    JE.object
        [ ( "account", JE.string "eosio.token" )
        , ( "action", JE.string "transfer" )
        , ( "payload"
          , JE.object
                [ ( "from", JE.string from )
                , ( "to", JE.string to )
                , ( "quantity", JE.string ((quantity |> formatEosQuantity) ++ " EOS") )
                , ( "memo", JE.string memo )
                ]
          )
        ]


encodeAction : Action -> JE.Value
encodeAction action =
    case action of
        Transfer message ->
            transferMessageToValue message



-- Internal helper functions.


formatEosQuantity : String -> String
formatEosQuantity =
    String.toFloat >> Result.withDefault 0 >> Round.round 4
