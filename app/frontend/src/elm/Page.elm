module Page exposing (Page(..), Message(..), getPage, update, view)

import Html exposing (Html)
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))


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



-- VIEW


view : Page -> Html Message
view page =
    case page of
        SearchPage subModel ->
            Html.map SearchMessage (Search.view subModel)

        VotingPage subModel ->
            Html.map VotingMessage (Voting.view subModel)

        TransferPage subModel ->
            Html.map TransferMessage (Transfer.view subModel)

        _ ->
            NotFound.view



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
