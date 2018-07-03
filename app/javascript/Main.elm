module Main exposing (..)

import Html exposing (Html, h1, text)
import Html.Attributes exposing (style)
import Port
import Wallet exposing (WalletStatus(NOTFOUND), decodeWalletStatus)


-- MODEL


type alias Model =
    { walletStatus : WalletStatus }



-- INIT


init : ( Model, Cmd Message )
init =
    ( { walletStatus = NOTFOUND }, Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    -- The inline style is being used for example purposes in order to keep this example simple and
    -- avoid loading additional resources. Use a proper stylesheet when building your own app.
    h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
        [ text "Hello Elm!" ]



-- MESSAGE


type Message
    = CheckWalletStatus
    | UpdateWalletStatus String
    | AuthenticateAccount
    | InvalidateAccount
    | None



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        UpdateWalletStatus str ->
            ( { model | walletStatus = (decodeWalletStatus str) }, Cmd.none )

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
