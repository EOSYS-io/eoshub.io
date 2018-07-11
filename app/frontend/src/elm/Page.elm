module Page exposing (Page(..), getPage)

import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))


type Page
    = IndexPage
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage


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
