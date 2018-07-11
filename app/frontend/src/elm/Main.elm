module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Message exposing (Message(..))
import Model exposing (Model, updatePage)
import Navigation exposing (Location)
import Page exposing (Page(..), getPage)
import Page.AccountCreate as AccountCreate
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Port
import Response exposing (decodeScatterResponse)
import Route exposing (Route(..), parseLocation)
import View.Notification
import Wallet exposing (decodeWalletStatus)


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

        AccountCreatePage subModel ->
            Html.map AccountCreateMessage (AccountCreate.view subModel)

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
