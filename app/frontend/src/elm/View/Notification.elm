module View.Notification exposing (Message(..), view)

import Html exposing (Html, div, text, h1)
import Html.Attributes exposing (class)
import Translation exposing (Language, translate, I18n(Success))


-- MESSAGE


type alias Detail =
    { code : Int
    , message : String
    }


type Message
    = Ok Detail
    | Error Detail
    | None



-- VIEW


view : Message -> Language -> Html message
view message language =
    let
        ( message_, c ) =
            case message of
                Ok _ ->
                    ( translate language Success, class "view success" )

                Error errorMessage ->
                    ( toString errorMessage.code ++ "\n" ++ errorMessage.message, class "view fail" )

                _ ->
                    ( "", class "" )
    in
        div [] []
