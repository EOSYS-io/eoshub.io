module Page exposing (Message(..), Page(..), getPage, update, view)

import Html exposing (Html)
import Page.Account.ConfirmEmail as ConfirmEmail
import Page.Account.Create as Create
import Page.Account.CreateKeys as CreateKeys
import Page.Account.Created as Created
import Page.Account.EmailConfirmFailure as EmailConfirmFailure
import Page.Account.EmailConfirmed as EmailConfirmed
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))
import Util.Flags exposing (Flags)


-- MODEL


type Page
    = IndexPage
    | ConfirmEmailPage ConfirmEmail.Model
    | EmailConfirmedPage EmailConfirmed.Model
    | EmailConfirmFailurePage EmailConfirmFailure.Model
    | CreatedPage Created.Model
    | CreateKeysPage CreateKeys.Model
    | CreatePage Create.Model
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage



-- MESSAGE


type Message
    = ConfirmEmailMessage ConfirmEmail.Message
    | EmailConfirmedMessage EmailConfirmed.Message
    | EmailConfirmFailureMessage EmailConfirmFailure.Message
    | CreateKeysMessage CreateKeys.Message
    | CreatedMessage Created.Message
    | CreateMessage Create.Message
    | SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message



-- VIEW


view : Page -> Html Message
view page =
    case page of
        ConfirmEmailPage subModel ->
            Html.map ConfirmEmailMessage (ConfirmEmail.view subModel)

        EmailConfirmedPage subModel ->
            Html.map EmailConfirmedMessage (EmailConfirmed.view subModel)

        EmailConfirmFailurePage subModel ->
            Html.map EmailConfirmFailureMessage (EmailConfirmFailure.view subModel)

        CreateKeysPage subModel ->
            Html.map CreateKeysMessage (CreateKeys.view subModel)

        CreatedPage subModel ->
            Html.map CreatedMessage (Created.view subModel)

        CreatePage subModel ->
            Html.map CreateMessage (Create.view subModel)

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
        ( ConfirmEmailMessage subMessage, ConfirmEmailPage subModel ) ->
            let
                ( newModel, subCmd ) =
                    ConfirmEmail.update subMessage subModel
            in
            ( newModel |> ConfirmEmailPage, Cmd.map ConfirmEmailMessage subCmd )

        ( EmailConfirmedMessage subMessage, EmailConfirmedPage subModel ) ->
            let
                newModel =
                    EmailConfirmed.update subMessage subModel
            in
            ( newModel |> EmailConfirmedPage, Cmd.none )

        ( EmailConfirmFailureMessage subMessage, EmailConfirmFailurePage subModel ) ->
            let
                newModel =
                    EmailConfirmFailure.update subMessage subModel
            in
            ( newModel |> EmailConfirmFailurePage, Cmd.none )

        ( CreateKeysMessage subMessage, CreateKeysPage subModel ) ->
            let
                newModel =
                    CreateKeys.update subMessage subModel
            in
            ( newModel |> CreateKeysPage, Cmd.none )

        ( CreatedMessage subMessage, CreatedPage subModel ) ->
            let
                newModel =
                    Created.update subMessage subModel
            in
            ( newModel |> CreatedPage, Cmd.none )

        ( CreateMessage subMessage, CreatePage subModel ) ->
            let
                ( newModel, subCmd ) =
                    Create.update subMessage subModel
            in
            ( newModel |> CreatePage, Cmd.map CreateMessage subCmd )

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
        ConfirmEmailRoute ->
            ConfirmEmailPage (ConfirmEmail.initModel flags)

        EmailConfirmedRoute confirmToken ->
            EmailConfirmedPage (EmailConfirmed.initModel ( flags, confirmToken ))

        EmailConfirmFailureRoute ->
            EmailConfirmFailurePage (EmailConfirmFailure.initModel flags)

        CreateKeysRoute ->
            CreateKeysPage (CreateKeys.initModel flags)

        CreatedRoute ->
            CreatedPage (Created.initModel flags)

        CreateRoute confirmToken pubkey ->
            CreatePage (Create.initModel ( flags, confirmToken, pubkey ))

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
