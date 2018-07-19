module Action exposing (Action(..), TransferParameters, transferParametersToValue, encodeAction)

import Json.Encode as JE
import Round


type alias TransferParameters =
    { from : String
    , to : String
    , quantity : String
    , memo : String
    }


type Action
    = Transfer TransferParameters


transferParametersToValue : TransferParameters -> JE.Value
transferParametersToValue { from, to, quantity, memo } =
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
            transferParametersToValue message



-- Internal helper functions.


formatEosQuantity : String -> String
formatEosQuantity =
    String.toFloat >> Result.withDefault 0 >> Round.round 4
