module View.Notification exposing (ErrorMessage, Message(..), view)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (style)
import Translation exposing (Language, translate, I18n(Success))


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


view : Message -> Language -> Html message
view message language =
    let
        ( message_, color ) =
            case message of
                Ok ->
                    ( translate language Success, "green" )

                Error errorMessage ->
                    ( toString errorMessage.code ++ "\n" ++ errorMessage.message, "red" )

                _ ->
                    ( "", "" )
    in
        div [ style [ ( "color", color ) ] ]
            [ h1 [] [ text message_ ] ]
