module Page.Transfer exposing (..)

import Action exposing (TransferParameters, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation
import Port
import Translation exposing (Language, translate, I18n(..))


-- MODEL


type alias Model =
    { transfer : TransferParameters }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    }



-- MESSAGE


type TransferMessageFormField
    = From
    | To
    | Quantity
    | Memo


type Message
    = SetTransferMessageField TransferMessageFormField String
    | SubmitAction
    | ChangeUrl String



-- VIEW
-- Note(heejae): Current url change logic is so messy.
-- Refactor url change logic using Navigation.urlUpdate.
-- See details of this approach from https://github.com/sircharleswatson/elm-navigation-example


view : Language -> Model -> Html Message
view language { transfer } =
    section [ class "action view panel transfer" ]
        [ nav []
            [ a
                [ style [ ( "cursor", "pointer" ) ]
                , onClick (ChangeUrl "/transfer")
                , class "viewing"
                ]
                [ text (translate language Translation.Transfer) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language RamMarket) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language Application) ]
            , a
                [ style [ ( "cursor", "pointer" ) ]
                , onClick (ChangeUrl "/voting")
                ]
                [ text (translate language Vote) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language ProxyVote) ]
            , a
                [ style [ ( "cursor", "pointer" ) ] ]
                [ text (translate language Faq) ]
            ]
        , h3 [] [ text (translate language Transfer) ]
        , p []
            [ text (translate language TransferInfo1)
            , br [] []
            , text (translate language TransferInfo2)
            ]
        , p [ class "help info" ]
            [ a [ style [ ( "cursor", "pointer" ) ] ] [ text (translate language TransferHelp) ]
            ]
        , div
            [ class "card" ]
            [ h4 []
                [ text (translate language TransferableAmount)
                , br [] []
                , strong [] [ text "120 EOS" ]
                ]
            , Html.form
                []
                [ ul []
                    [ li [ class "account" ]
                        [ input
                            [ id "rcvAccount"
                            , type_ "text"
                            , style [ ( "color", "white" ) ]
                            , placeholder (translate language ReceiverAccountName)
                            , onInput <| SetTransferMessageField To
                            , value transfer.to
                            ]
                            []
                        , span [] [ text (translate language CheckAccountName) ]
                        ]
                    , li [ class "eos" ]
                        [ input
                            [ id "eos"
                            , type_ "number"
                            , style [ ( "color", "white" ) ]
                            , placeholder "0.0000"
                            , onInput <| SetTransferMessageField Quantity
                            , value transfer.quantity
                            ]
                            []
                        , span [ class "warning" ]
                            [ text (translate language OverTransferableAmount) ]
                        ]
                    , li [ class "memo" ]
                        [ input
                            [ id "memo"
                            , type_ "text"
                            , style [ ( "color", "white" ) ]
                            , placeholder (translate language Translation.Memo)
                            , onInput <| SetTransferMessageField Memo
                            , value transfer.memo
                            ]
                            []
                        , span [] [ text (translate language OverTransferableAmount) ]
                        ]
                    ]
                , div
                    [ class "btn_area" ]
                    [ button
                        [ type_ "button"
                        , id "send"
                        , class "middle blue_white"
                        , onClick SubmitAction
                        ]
                        [ text (translate language Transfer) ]
                    ]
                ]
            ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ transfer } as model) =
    case message of
        SubmitAction ->
            let
                cmd =
                    transfer |> Action.Transfer |> encodeAction |> Port.pushAction
            in
                ( model, cmd )

        SetTransferMessageField field value ->
            ( setTransferMessageField field value model, Cmd.none )

        ChangeUrl url ->
            ( model, Navigation.newUrl url )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Model
setTransferMessageField field value model =
    let
        transfer =
            model.transfer
    in
        case field of
            From ->
                { model | transfer = { transfer | from = value } }

            To ->
                { model | transfer = { transfer | to = value } }

            Quantity ->
                { model | transfer = { transfer | quantity = value } }

            Memo ->
                { model | transfer = { transfer | memo = value } }
