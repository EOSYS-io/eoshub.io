module View.Notification exposing (ErrorMessage, Message(..), view)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (style)


-- MESSAGE


type alias ErrorMessage =
    { code : Int
    , message : String
    }


type Message
    = Ok
    | Error ErrorMessage
    | None



-- VIEW


view : Message -> Html message
view message =
    let
        ( message_, color ) =
            case message of
                Ok ->
                    ( "Success!", "green" )

                Error errorMessage ->
                    ( toString errorMessage.code ++ "\n" ++ errorMessage.message, "red" )

                _ ->
                    ( "", "" )
    in
        div [ style [ ( "color", color ) ] ]
            [ h1 [] [ text message_ ] ]
