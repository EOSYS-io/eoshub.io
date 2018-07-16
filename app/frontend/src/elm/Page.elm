module Page exposing (Message(..), Page(..), getPage, update, view)

import Html exposing (Html)
import Page.AccountCreate as AccountCreate
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))
import Util.Flags exposing (Flags)


-- MODEL


type Page
    = IndexPage
    | AccountCreatePage AccountCreate.Model
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage



-- MESSAGE


type Message
    = AccountCreateMessage AccountCreate.Message
    | SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message



-- VIEW


view : Page -> Html Message
view page =
    case page of
        AccountCreatePage subModel ->
            Html.map AccountCreateMessage (AccountCreate.view subModel)

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
        ( AccountCreateMessage subMessage, AccountCreatePage subModel ) ->
            let
                ( newModel, subCmd ) =
                    AccountCreate.update subMessage subModel
            in
            ( newModel |> AccountCreatePage, Cmd.map AccountCreateMessage subCmd )

        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                newModel =
                    Search.update subMessage subModel
            in
            ( newModel |> SearchPage, Cmd.none )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newModel, subCmd ) =
                    Transfer.update subMessage subModel
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


getPage : ( Route, Flags ) -> Page
getPage ( route, flags ) =
    case route of
        AccountCreateRoute ->
            AccountCreatePage (AccountCreate.initModel flags)

        SearchRoute ->
            SearchPage (Search.initModel flags)

        VotingRoute ->
            VotingPage (Voting.initModel flags)

        TransferRoute ->
            TransferPage (Transfer.initModel flags)

        IndexRoute ->
            IndexPage

        _ ->
            NotFoundPage
