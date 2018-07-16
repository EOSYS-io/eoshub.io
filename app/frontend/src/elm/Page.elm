module Page exposing (Message(..), Page(..), getPage, update, view)

import Html exposing (Html)
import Page.AccountCreate.EmailConfirmFailure as EmailConfirmFailure
import Page.AccountCreate.EmailConfirmed as EmailConfirmed
import Page.AccountCreate.SendEmail as SendEmail
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))
import Util.Flags exposing (Flags)


-- MODEL


type Page
    = IndexPage
    | SendEmailPage SendEmail.Model
    | EmailConfirmedPage EmailConfirmed.Model
    | EmailConfirmFailurePage EmailConfirmFailure.Model
    | SearchPage Search.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage



-- MESSAGE


type Message
    = SendEmailMessage SendEmail.Message
    | EmailConfirmedMessage EmailConfirmed.Message
    | EmailConfirmFailureMessage EmailConfirmFailure.Message
    | SearchMessage Search.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message



-- VIEW


view : Page -> Html Message
view page =
    case page of
        SendEmailPage subModel ->
            Html.map SendEmailMessage (SendEmail.view subModel)

        EmailConfirmedPage subModel ->
            Html.map EmailConfirmedMessage (EmailConfirmed.view subModel)

        EmailConfirmFailurePage subModel ->
            Html.map EmailConfirmFailureMessage (EmailConfirmFailure.view subModel)

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
        ( SendEmailMessage subMessage, SendEmailPage subModel ) ->
            let
                ( newModel, subCmd ) =
                    SendEmail.update subMessage subModel
            in
            ( newModel |> SendEmailPage, Cmd.map SendEmailMessage subCmd )

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
        SendEmailRoute ->
            SendEmailPage (SendEmail.initModel flags)

        EmailConfirmedRoute confirmToken ->
            EmailConfirmedPage (EmailConfirmed.initModel ( flags, confirmToken ))

        EmailConfirmFailureRoute ->
            EmailConfirmFailurePage (EmailConfirmFailure.initModel flags)

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
