module Page exposing (Page(..), Message(..), getPage, update, view)

import ExternalMessage
import Html exposing (Html)
import Navigation
import Page.Index as Index
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))
import Translation exposing (Language)


-- MODEL


type Page
    = IndexPage
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage



-- MESSAGE


type Message
    = SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
    | IndexMessage ExternalMessage.Message



-- VIEW


view : Language -> Page -> Html Message
view language page =
    case page of
        SearchPage subModel ->
            Html.map SearchMessage (Search.view language subModel)

        VotingPage subModel ->
            Html.map VotingMessage (Voting.view language subModel)

        TransferPage subModel ->
            Html.map TransferMessage (Transfer.view language subModel)

        IndexPage ->
            Html.map IndexMessage (Index.view language)

        _ ->
            NotFound.view language



-- UPDATE


update : Message -> Page -> ( Page, Cmd Message )
update message page =
    case ( message, page ) of
        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                newModel =
                    Search.update subMessage subModel
            in
                ( newModel |> SearchPage, Cmd.none )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newModel, subCmd ) =
                    (Transfer.update subMessage subModel)
            in
                ( newModel |> TransferPage, Cmd.map TransferMessage subCmd )

        ( VotingMessage subMessage, VotingPage subModel ) ->
            let
                newModel =
                    Voting.update subMessage subModel
            in
                ( newModel |> VotingPage, Cmd.none )

        ( IndexMessage subMessage, _ ) ->
            case subMessage of
                ExternalMessage.ChangeUrl url ->
                    ( page, Navigation.newUrl url )

        ( _, _ ) ->
            ( page, Cmd.none )



-- Utility functions


getPage : Route -> Page
getPage route =
    case route of
        SearchRoute ->
            SearchPage Search.initModel

        VotingRoute ->
            VotingPage Voting.initModel

        TransferRoute ->
            TransferPage Transfer.initModel

        IndexRoute ->
            IndexPage

        _ ->
            NotFoundPage
