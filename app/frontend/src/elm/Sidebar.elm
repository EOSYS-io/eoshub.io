module Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import View.Notification
import Port
import Response exposing (decodeScatterResponse)


-- MODEL


type WalletStatus
    = Authenticated
    | Loaded
    | NotFound


type alias Model =
    { wallet :
        { status : WalletStatus
        , account : String
        , authority : String
        }
    , notification : View.Notification.Message
    }


initModel : Model
initModel =
    { wallet =
        { status = NotFound
        , account = ""
        , authority = ""
        }
    , notification = View.Notification.None
    }



-- MESSAGE


type Message
    = CheckWalletStatus
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
    | UpdateScatterResponse { code : Int, type_ : String, message : String }



-- VIEW


view : Model -> Html Message
view { wallet, notification } =
    div []
        [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
            [ text "Hello Elm!" ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text wallet.account ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text wallet.authority ]
        , button [ onClick CheckWalletStatus ] [ text "Check" ]
        , button [ onClick AuthenticateAccount ] [ text "Attach Scatter" ]
        , button [ onClick InvalidateAccount ] [ text "Detach Scatter" ]
        , div [] [ View.Notification.view notification ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UpdateWalletStatus { status, account, authority } ->
            if status == "WALLET_STATUS_AUTHENTICATED" then
                ( { model | wallet = { status = Authenticated, account = account, authority = authority } }, Cmd.none )
            else if status == "WALLET_STATUS_LOADED" then
                ( { model | wallet = { status = Loaded, account = "", authority = "" } }, Cmd.none )
            else
                ( { model | wallet = { status = NotFound, account = "", authority = "" } }, Cmd.none )

        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        UpdateScatterResponse resp ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.batch
        [ Port.receiveWalletStatus UpdateWalletStatus
        , Port.receiveScatterResponse UpdateScatterResponse
        ]
