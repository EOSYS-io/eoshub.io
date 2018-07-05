module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Action exposing (Action(Transfer), TransferMsg, encodeAction)
import Port
import Wallet exposing (WalletStatus, Status(NotFound), decodeWalletStatus)


-- MODEL


type alias Model =
    { walletStatus : Wallet.WalletStatus
    , transferMsg : TransferMsg
    }


type TransferMsgFormField
    = From
    | To
    | Quantity
    | Memo



-- INIT


init : ( Model, Cmd Message )
init =
    ( { walletStatus = { status = NotFound, account = "", authority = "" }
      , transferMsg = { from = "", to = "", quantity = "", memo = "" }
      }
    , Cmd.none
    )


setTransferMsgField : TransferMsgFormField -> String -> Model -> Model
setTransferMsgField field value ({ transferMsg } as model) =
    case field of
        From ->
            { model | transferMsg = { transferMsg | from = value } }

        To ->
            { model | transferMsg = { transferMsg | to = value } }

        Quantity ->
            { model | transferMsg = { transferMsg | quantity = value } }

        Memo ->
            { model | transferMsg = { transferMsg | memo = value } }



-- VIEW


view : Model -> Html Message
view { walletStatus, transferMsg } =
    -- TODO(heejae): Split transfer form to a separate file.
    div []
        [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
            [ text "Hello Elm!" ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text walletStatus.account ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text walletStatus.authority ]
        , button [ onClick CheckWalletStatus ] [ text "Check" ]
        , button [ onClick AuthenticateAccount ] [ text "Attach Scatter" ]
        , button [ onClick InvalidateAccount ] [ text "Detach Scatter" ]
        , div []
            [ Html.form
                [ onSubmit SubmitAction ]
                [ label []
                    [ text "From"
                    , input
                        [ type_ "text"
                        , placeholder "From"
                        , onInput <| (SetTransferMsgField From)
                        , value transferMsg.from
                        ]
                        []
                    ]
                , label []
                    [ text "To"
                    , input
                        [ type_ "text"
                        , placeholder "To"
                        , onInput <| SetTransferMsgField To
                        , value transferMsg.to
                        ]
                        []
                    ]
                , label []
                    [ text "Quantity"
                    , input
                        [ type_ "text"
                        , placeholder "EOS"
                        , onInput <| SetTransferMsgField Quantity
                        , value transferMsg.quantity
                        ]
                        []
                    ]
                , label []
                    [ text "Memo"
                    , input
                        [ type_ "text"
                        , placeholder "Memo"
                        , onInput <| SetTransferMsgField Memo
                        , value transferMsg.memo
                        ]
                        []
                    ]
                , button
                    []
                    [ text "Submit" ]
                ]
            ]
        ]



-- MESSAGE


type Message
    = CheckWalletStatus -- TODO(heejae): Modify CheckWalletStatus to have a name of Wallet plugin(ex. Scatter).
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
    | SetTransferMsgField TransferMsgFormField String
    | SubmitAction
    | None



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        UpdateWalletStatus payload ->
            ( { model | walletStatus = (decodeWalletStatus payload) }, Cmd.none )

        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        SubmitAction ->
            ( model, (encodeAction (Transfer model.transferMsg)) |> Port.pushAction )

        SetTransferMsgField field value ->
            ( setTransferMsgField field value model, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Port.receiveWalletStatus UpdateWalletStatus



-- MAIN


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
