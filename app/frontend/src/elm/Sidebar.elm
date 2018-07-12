module Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Port
import Response exposing (decodeScatterResponse)
import Translation exposing (Language(..))
import View.Notification


-- MODEL


type WalletStatus
    = Authenticated
    | Loaded
    | NotFound


type alias Model =
    { language : Language
    , notification : View.Notification.Message
    , wallet :
        { status : WalletStatus
        , account : String
        , authority : String
        }
    }


initModel : Model
initModel =
    { language = English
    , notification = View.Notification.None
    , wallet =
        { status = NotFound
        , account = ""
        , authority = ""
        }
    }



-- MESSAGE


type Message
    = AuthenticateAccount
    | CheckWalletStatus
    | InvalidateAccount
    | UpdateLanguage Language
    | UpdateScatterResponse { code : Int, type_ : String, message : String }
    | UpdateWalletStatus { status : String, account : String, authority : String }



-- VIEW


view : Model -> Html Message
view { wallet, notification, language } =
    div []
        [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
            [ text "Hello Elm!" ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text wallet.account ]
        , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text wallet.authority ]
        , button [ onClick CheckWalletStatus ] [ text "Check" ]
        , button [ onClick AuthenticateAccount ] [ text "Attach Scatter" ]
        , button [ onClick InvalidateAccount ] [ text "Detach Scatter" ]
        , button [ onClick (UpdateLanguage Korean) ] [ text "KO" ]
        , button [ onClick (UpdateLanguage English) ] [ text "EN" ]
        , div [] [ View.Notification.view notification language ]
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        UpdateLanguage language ->
            ( { model | language = language }, Cmd.none )

        UpdateScatterResponse resp ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

        UpdateWalletStatus { status, account, authority } ->
            if status == "WALLET_STATUS_AUTHENTICATED" then
                ( { model | wallet = { status = Authenticated, account = account, authority = authority } }, Cmd.none )
            else if status == "WALLET_STATUS_LOADED" then
                ( { model | wallet = { status = Loaded, account = "", authority = "" } }, Cmd.none )
            else
                ( { model | wallet = { status = NotFound, account = "", authority = "" } }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.batch
        [ Port.receiveWalletStatus UpdateWalletStatus
        , Port.receiveScatterResponse UpdateScatterResponse
        ]
