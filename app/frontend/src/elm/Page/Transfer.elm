module Page.Transfer exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Action exposing (Action(Transfer), TransferMsg, encodeAction)
import Port


-- MODEL


type alias Model =
    { transfer : TransferMsg }


initModel : Model
initModel =
    { transfer = { from = "", to = "", quantity = "", memo = "" }
    }



-- MESSAGE


type TransferMsgFormField
    = From
    | To
    | Quantity
    | Memo


type Message
    = SetTransferMsgField TransferMsgFormField String
    | SubmitAction



-- VIEW


view : Model -> Html Message
view { transfer } =
    div []
        [ div []
            [ Html.form
                [ onSubmit SubmitAction ]
                [ label []
                    [ text "From"
                    , input
                        [ type_ "text"
                        , placeholder "From"
                        , onInput <| SetTransferMsgField From
                        , value transfer.from
                        ]
                        []
                    ]
                , label []
                    [ text "To"
                    , input
                        [ type_ "text"
                        , placeholder "To"
                        , onInput <| SetTransferMsgField To
                        , value transfer.to
                        ]
                        []
                    ]
                , label []
                    [ text "Quantity"
                    , input
                        [ type_ "text"
                        , placeholder "EOS"
                        , onInput <| SetTransferMsgField Quantity
                        , value transfer.quantity
                        ]
                        []
                    ]
                , label []
                    [ text "Memo"
                    , input
                        [ type_ "text"
                        , placeholder "Memo"
                        , onInput <| SetTransferMsgField Memo
                        , value transfer.memo
                        ]
                        []
                    ]
                , button
                    []
                    [ text "Submit" ]
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
                    transfer |> Transfer |> encodeAction |> Port.pushAction
            in
                ( model, cmd )

        SetTransferMsgField field value ->
            ( setTransferMsgField field value model, Cmd.none )



-- Utility functions.


setTransferMsgField : TransferMsgFormField -> String -> Model -> Model
setTransferMsgField field value { transfer } =
    case field of
        From ->
            { transfer = { transfer | from = value } }

        To ->
            { transfer = { transfer | to = value } }

        Quantity ->
            { transfer = { transfer | quantity = value } }

        Memo ->
            { transfer = { transfer | memo = value } }
