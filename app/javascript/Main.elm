module Main exposing (..)

import Html exposing (Html, div, button, h1, h2, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Port
import Wallet exposing (WalletStatus, Status(NOTFOUND), decodeWalletStatus)


-- MODEL


type alias Model =
    { walletStatus : Wallet.WalletStatus }



-- INIT


init : ( Model, Cmd Message )
init =
    ( { walletStatus = { status = NOTFOUND, account = "", authority = "" } }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    -- The inline style is being used for example purposes in order to keep this example simple and
    -- avoid loading additional resources. Use a proper stylesheet when building your own app.
    div []
        [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
            [ text "Hello Elm!" ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text model.walletStatus.account ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text model.walletStatus.authority ]
        , button [ onClick CheckWalletStatus ] [ text "Check" ]
        , button [ onClick AuthenticateAccount ] [ text "Attach Scatter" ]
        , button [ onClick InvalidateAccount ] [ text "Detach Scatter" ]
        ]



-- MESSAGE
-- TODO(heejae): Modify CheckWalletStatus to have a name of Wallet plugin(ex. Scatter).


type Message
    = CheckWalletStatus
    | UpdateWalletStatus { status : String, account : String, authority : String }
    | AuthenticateAccount
    | InvalidateAccount
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
