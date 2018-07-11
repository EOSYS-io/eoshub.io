module Action exposing (TransferMsg, Action(..), transferMsgToValue, encodeAction)

import Json.Encode as JE
import Round


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
        Transfer msg ->
            transferMsgToValue msg



-- Internal helper functions.


formatEosQuantity : String -> String
formatEosQuantity =
    String.toFloat >> Result.withDefault 0 >> Round.round 4
