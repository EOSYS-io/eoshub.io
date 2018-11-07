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
    | MoveToCpunetPage



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
        ( texts, isError ) =
            case content of
                Ok { message, detail } ->
                    ( ( translate language message
                      , "view success"
                      , translate language detail
                      )
                    , False
                    )

                Error { message, detail } ->
                    ( ( translate language message
                      , "view fail"
                      , translate language detail
                      )
                    , True
                    )

                _ ->
                    ( ( "", "", "" ), False )

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
        [ messageBox texts language isError ]


messageBox : ( String, String, String ) -> Language -> Bool -> Html Message
messageBox ( mainText, classText, detailText ) language isError =
    div [ class classText ]
        (if String.isEmpty detailText then
            [ messageBoxMainText mainText
            , messageBoxButton language
            ]

         else
            [ messageBoxMainText mainText
            , messageBoxDetailText detailText isError
            , messageBoxButton language
            ]
        )


messageBoxMainText : String -> Html Message
messageBoxMainText mainText =
    p [] [ text mainText ]



-- NOTE(heejae): Currently, it routes to resource page when error occurs.
-- Consider refactoring error messages to receive msg as parameter to handle other cases.


messageBoxDetailText : String -> Bool -> Html Message
messageBoxDetailText detailText isError =
    a
        [ onClick
            (if isError then
                MoveToCpunetPage

             else
                MoveToAccountPage
            )
        ]
        [ text detailText ]


messageBoxButton : Language -> Html Message
messageBoxButton language =
    button
        [ type_ "button"
        , class "icon close button"
        , onClick CloseNotification
        ]
        [ text (translate language Close) ]
