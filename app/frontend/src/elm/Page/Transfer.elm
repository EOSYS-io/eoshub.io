module Page.Transfer exposing (..)

import Action exposing (Action(Transfer), TransferMessage, encodeAction)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Port
import Translation exposing (Language)


-- MODEL


type alias Model =
    { transfer : TransferMessage }


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



-- VIEW


view : Language -> Model -> Html Message
view _ { transfer } =
    div []
        [ div []
            [ Html.form
                [ onSubmit SubmitAction ]
                [ label []
                    [ text "From"
                    , input
                        [ type_ "text"
                        , placeholder "From"
                        , onInput <| SetTransferMessageField From
                        , value transfer.from
                        ]
                        []
                    ]
                , label []
                    [ text "To"
                    , input
                        [ type_ "text"
                        , placeholder "To"
                        , onInput <| SetTransferMessageField To
                        , value transfer.to
                        ]
                        []
                    ]
                , label []
                    [ text "Quantity"
                    , input
                        [ type_ "text"
                        , placeholder "EOS"
                        , onInput <| SetTransferMessageField Quantity
                        , value transfer.quantity
                        ]
                        []
                    ]
                , label []
                    [ text "Memo"
                    , input
                        [ type_ "text"
                        , placeholder "Memo"
                        , onInput <| SetTransferMessageField Memo
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

        SetTransferMessageField field value ->
            ( setTransferMessageField field value model, Cmd.none )



-- Utility functions.


setTransferMessageField : TransferMessageFormField -> String -> Model -> Model
setTransferMessageField field value { transfer } =
    case field of
        From ->
            { transfer = { transfer | from = value } }

        To ->
            { transfer = { transfer | to = value } }

        Quantity ->
            { transfer = { transfer | quantity = value } }

        Memo ->
            { transfer = { transfer | memo = value } }
