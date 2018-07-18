module Page exposing (..)

import ExternalMessage
import Html exposing (Html)
import Navigation exposing (Location)
import Page.Account.ConfirmEmail as ConfirmEmail
import Page.Account.Create as Create
import Page.Account.CreateKeys as CreateKeys
import Page.Account.Created as Created
import Page.Account.EmailConfirmFailure as EmailConfirmFailure
import Page.Account.EmailConfirmed as EmailConfirmed
import Page.Index as Index
import Page.NotFound as NotFound
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Port
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Util.WalletDecoder exposing (ScatterResponse, decodeScatterResponse)
import View.Notification


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


type alias Model =
    { page : Page
    , notification : View.Notification.Message
    , confirmToken : String
    }


initModel : Location -> Model
initModel location =
    { page = getPage location ""
    , notification = View.Notification.None
    , confirmToken = ""
    }



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
    | IndexMessage ExternalMessage.Message
    | UpdateScatterResponse ScatterResponse
    | OnLocationChange Location



-- VIEW


view : Language -> Model -> Html Message
view language { page } =
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


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message ({ page } as model) flags =
    case ( message, page ) of
        ( ConfirmEmailMessage subMessage, ConfirmEmailPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    ConfirmEmail.update subMessage subModel flags
            in
                ( { model | page = newPage |> ConfirmEmailPage }, Cmd.map ConfirmEmailMessage subCmd )

        ( EmailConfirmedMessage subMessage, EmailConfirmedPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    EmailConfirmed.update subMessage subModel
            in
                ( { model | page = newPage |> EmailConfirmedPage }, Cmd.map EmailConfirmedMessage subCmd )

        ( EmailConfirmFailureMessage subMessage, EmailConfirmFailurePage subModel ) ->
            let
                newPage =
                    EmailConfirmFailure.update subMessage subModel
            in
                ( { model | page = newPage |> EmailConfirmFailurePage }, Cmd.none )

        ( CreateKeysMessage subMessage, CreateKeysPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    CreateKeys.update subMessage subModel
            in
                ( { model | page = newPage |> CreateKeysPage }, Cmd.map CreateKeysMessage subCmd )

        ( CreatedMessage subMessage, CreatedPage subModel ) ->
            let
                newPage =
                    Created.update subMessage subModel
            in
                ( { model | page = newPage |> CreatedPage }, Cmd.none )

        ( CreateMessage subMessage, CreatePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Create.update subMessage subModel flags
            in
                ( { model | page = newPage |> CreatePage }, Cmd.map CreateMessage subCmd )

        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                newPage =
                    Search.update subMessage subModel
            in
                ( { model | page = newPage |> SearchPage }, Cmd.none )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Transfer.update subMessage subModel
            in
                ( { model | page = newPage |> TransferPage }, Cmd.map TransferMessage subCmd )

        ( VotingMessage subMessage, VotingPage subModel ) ->
            let
                newPage =
                    Voting.update subMessage subModel
            in
                ( { model | page = newPage |> VotingPage }, Cmd.none )

        ( IndexMessage (ExternalMessage.ChangeUrl url), _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdateScatterResponse resp, _ ) ->
            ( { model | notification = resp |> decodeScatterResponse }, Cmd.none )

        ( OnLocationChange location, _ ) ->
            case page of
                EmailConfirmedPage subModel ->
                    let
                        createKeysModel =
                            CreateKeys.initModel model.confirmToken

                        ( newCreateKeysModel, subCmd ) =
                            CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                        newPage =
                            CreateKeysPage newCreateKeysModel
                    in
                        ( { model | page = newPage, confirmToken = subModel.confirmToken }, Cmd.map CreateKeysMessage subCmd )

                _ ->
                    let
                        newPage =
                            getPage location model.confirmToken
                    in
                        ( { model | page = newPage }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Sub.map CreateKeysMessage CreateKeys.subscriptions
        , Port.receiveScatterResponse UpdateScatterResponse
        ]



-- Utility functions


getPage : Location -> String -> Page
getPage location confirmToken =
    let
        route =
            location |> parseLocation
    in
        case route of
            ConfirmEmailRoute ->
                ConfirmEmailPage ConfirmEmail.initModel

            EmailConfirmedRoute confirmToken ->
                EmailConfirmedPage (EmailConfirmed.initModel confirmToken)

            EmailConfirmFailureRoute ->
                EmailConfirmFailurePage EmailConfirmFailure.initModel

            CreateKeysRoute ->
                CreateKeysPage (CreateKeys.initModel confirmToken)

            CreatedRoute ->
                CreatedPage Created.initModel

            CreateRoute pubkey ->
                CreatePage (Create.initModel ( confirmToken, pubkey ))

            SearchRoute ->
                SearchPage Search.initModel

            VotingRoute ->
                VotingPage Voting.initModel

            TransferRoute ->
                TransferPage Transfer.initModel

            IndexRoute ->
                IndexPage

            NotFoundRoute ->
                NotFoundPage
