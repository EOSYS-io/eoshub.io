module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Message exposing (..)
import Model exposing (..)
import Port
import Wallet exposing (decodeWalletStatus)
import Response exposing (decodeScatterResponse)
import Navigation exposing (Location)
import Route exposing (..)
import Page exposing (..)
import Page.Search as Search
import Page.Voting as Voting
import Page.NotFound as NotFound
import Page.Transfer as Transfer
import View.Notification


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

        SearchPage subModel ->
            Html.map SearchMessage (Search.view subModel)

        VotingPage subModel ->
            Html.map VotingMessage (Voting.view subModel)

        TransferPage subModel ->
            Html.map TransferMessage (Transfer.view subModel)

        NotFoundPage ->
            NotFound.view



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

        _ ->
            updatePage message model.page model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
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
