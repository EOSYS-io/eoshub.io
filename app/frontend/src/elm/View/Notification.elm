{- This module is a so-called viewModel -}


module View.Notification
    exposing
        ( ErrorDetail
        , Message(..)
        , Model
        , Content(..)
        , initModel
        , view
        )

import Html exposing (Html, div, text, p, a, button)
import Html.Attributes exposing (class, type_, id)
import Html.Events exposing (onClick)
import Translation exposing (Language, translate, I18n(CheckDetail, CheckError, Close))


-- MESSAGE


type Message
    = CloseNotification



-- MODEL


type alias ErrorDetail =
    { message : I18n
    , detail : String
    }


type Content
    = Ok (String -> I18n)
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


view : Model -> String -> Language -> Html Message
view { content, open } i18nParam language =
    let
        texts =
            case content of
                Ok messageGenerator ->
                    ( translate language (i18nParam |> messageGenerator)
                    , "view success"
                    , translate language CheckDetail
                    )

                Error { message } ->
                    ( translate language message
                    , "view fail"
                    , translate language CheckError
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
        [ p [] [ text mainText ]
        , a [] [ text detailText ]
        , button
            [ type_ "button"
            , class "icon close button"
            , onClick CloseNotification
            ]
            [ text (translate language Close) ]
        ]
