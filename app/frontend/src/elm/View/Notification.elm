{- This module is a so-called viewModel -}


module View.Notification exposing
    ( Content(..)
    , ErrorDetail
    , Message(..)
    , Model
    , initModel
    , view
    )

import Html exposing (Html, a, button, div, p, text)
import Html.Attributes exposing (class, id, type_)
import Html.Events exposing (onClick)
import Translation exposing (I18n(Close), Language, translate)



-- MESSAGE


type Message
    = CloseNotification
    | MoveToAccountPage



-- MODEL


type alias OkDetail =
    { message : I18n
    , detail : I18n
    }


type alias ErrorDetail =
    { message : I18n
    , detail : I18n
    }


type Content
    = Ok OkDetail
    | Error ErrorDetail
    | None


type alias Model =
    { content : Content
    , open : Bool
    }


initModel : Model
initModel =
    { content = None
    , open = False
    }



-- VIEW


view : Model -> Language -> Html Message
view { content, open } language =
    let
        texts =
            case content of
                Ok { message, detail } ->
                    ( translate language message
                    , "view success"
                    , translate language detail
                    )

                Error { message, detail } ->
                    ( translate language message
                    , "view fail"
                    , translate language detail
                    )

                _ ->
                    ( "", "", "" )

        viewing =
            if open then
                " viewing"

            else
                ""
    in
    div
        [ id "notification"
        , class ("notification panel" ++ viewing)
        ]
        [ messageBox texts language ]


messageBox : ( String, String, String ) -> Language -> Html Message
messageBox ( mainText, classText, detailText ) language =
    div [ class classText ]
        (if String.isEmpty detailText then
            [ messageBoxMainText mainText
            , messageBoxButton language
            ]

         else
            [ messageBoxMainText mainText
            , messageBoxDetailText detailText
            , messageBoxButton language
            ]
        )


messageBoxMainText : String -> Html Message
messageBoxMainText mainText =
    p [] [ text mainText ]


messageBoxDetailText : String -> Html Message
messageBoxDetailText detailText =
    a [ onClick MoveToAccountPage ] [ text detailText ]


messageBoxButton : Language -> Html Message
messageBoxButton language =
    button
        [ type_ "button"
        , class "icon close button"
        , onClick CloseNotification
        ]
        [ text (translate language Close) ]
