module Data.WindowOpen exposing (WindowOpenParameters, windowOpenParametersToValue)

import Json.Encode as Encode


type alias WindowOpenParameters =
    { url : String
    , width : Int
    , height : Int
    }


windowOpenParametersToValue : WindowOpenParameters -> Encode.Value
windowOpenParametersToValue { url, width, height } =
    -- Introduce form validation.
    Encode.object
        [ ( "url", Encode.string url )
        , ( "width", Encode.int width )
        , ( "height", Encode.int height )
        ]
