module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Message exposing (Message(..))
import Navigation exposing (Location)
import Page exposing (Page(..), getPage)
import Port
import Response exposing (decodeScatterResponse)
import Route exposing (Route(..), parseLocation)
import View.Notification
import Wallet exposing (decodeWalletStatus)


-- MODEL


type alias Model =
    { walletStatus : Wallet.WalletStatus
    , page : Page
    , notification : View.Notification.Msg
    }



-- INIT


init : Location -> ( Model, Cmd Message )
init location =
    ( { walletStatus = { status = Wallet.NotFound, account = "", authority = "" }
      , page = location |> Route.parseLocation |> getPage
      , notification = View.Notification.None
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Message
view { walletStatus, page, notification } =
    case page of
        IndexPage ->
            div []
                [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
                    [ text "Hello Elm!" ]
                , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text walletStatus.account ]
                , h2 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ] [ text walletStatus.authority ]
                , button [ onClick CheckWalletStatus ] [ text "Check" ]
                , button [ onClick AuthenticateAccount ] [ text "Attach Scatter" ]
                , button [ onClick InvalidateAccount ] [ text "Detach Scatter" ]
                , div [] [ View.Notification.view notification ]
                ]

        _ ->
            Html.map PageMessage (Page.view page)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CheckWalletStatus ->
            ( model, Port.checkWalletStatus () )

        UpdateWalletStatus payload ->
            ( { model | walletStatus = decodeWalletStatus payload }, Cmd.none )

        AuthenticateAccount ->
            ( model, Port.authenticateAccount () )

        InvalidateAccount ->
            ( model, Port.invalidateAccount () )

        UpdateScatterResponse resp ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

        OnLocationChange location ->
            ( { model | page = location |> parseLocation |> getPage }, Cmd.none )

        PageMessage pageMessage ->
            let
                ( newPage, newCmd ) =
                    Page.update pageMessage model.page
            in
                ( { model | page = newPage }, Cmd.map PageMessage newCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions _ =
    Sub.batch
        [ Port.receiveWalletStatus UpdateWalletStatus
        , Port.receiveScatterResponse UpdateScatterResponse
        ]



-- MAIN


main : Program Never Model Message
main =
    Navigation.program OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
