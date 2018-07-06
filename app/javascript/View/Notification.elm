module View.Notification exposing (..)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (style)


type alias ErrorMsg =
    { code : Int
    , message : String
    }


type Msg
    = Ok
    | Error ErrorMsg
    | None


view : Msg -> Html msg
view msg =
    let
        ( message, color ) =
            case msg of
                Ok ->
                    ( "Success!", "green" )

                Error { code, message } ->
                    ( toString code ++ "\n" ++ message, "red" )

                _ ->
                    ( "", "" )
    in
        div [ style [ ( "color", color ) ] ]
            [ h1 [] [ text message ] ]
