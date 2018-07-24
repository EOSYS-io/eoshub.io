module Page exposing (..)

import Html
    exposing
        ( Html
        , Attribute
        , div
        , section
        , form
        , ul
        , li
        , span
        , input
        , button
        , text
        )
import Html.Attributes
    exposing
        ( placeholder
        , disabled
        , class
        , attribute
        , type_
        )
import Html.Events exposing (on, onInput, onClick, keyCode)
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
import Page.SearchKey as SearchKey
import Page.Transfer as Transfer
import Page.Voting as Voting
import Port
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Util.WalletDecoder exposing (Wallet, PushActionResponse, decodePushActionResponse)
import Json.Decode as JD exposing (Decoder)
import Regex exposing (regex, contains)
import View.Notification as Notification


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
    | SearchKeyPage SearchKey.Model
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , notification : Notification.Model
    , header : Header
    }


type alias Header =
    { searchInput : String
    , eosPrice : Int
    , ramPrice : Int
    , errMessage : String
    }


initModel : Location -> ( Model, Cmd Message )
initModel location =
    let
        ( page, cmd ) =
            getPage location
    in
        ( { page = page
          , notification = Notification.initModel
          , header =
                { searchInput = ""
                , eosPrice = 0
                , ramPrice = 0
                , errMessage = ""
                }
          }
        , cmd
        )



-- MESSAGE


type Message
    = ConfirmEmailMessage ConfirmEmail.Message
    | EmailConfirmedMessage EmailConfirmed.Message
    | EmailConfirmFailureMessage EmailConfirmFailure.Message
    | CreateKeysMessage CreateKeys.Message
    | CreatedMessage Created.Message
    | CreateMessage Create.Message
    | SearchMessage Search.Message
    | SearchKeyMessage SearchKey.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
    | IndexMessage Index.Message
    | InputSearch String
    | UpdatePushActionResponse PushActionResponse
    | CheckSearchQuery String
    | OnLocationChange Location
    | NotificationMessage Notification.Message


type Query
    = AccountQuery
    | PublicKeyQuery


type alias AccountQuery =
    String


type alias PublicKeyQuery =
    String



-- VIEW


view : Language -> Model -> List (Html Message)
view language { page, header, notification } =
    let
        newContentHtml =
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

        notificationParameter =
            case page of
                TransferPage { transfer } ->
                    transfer.to

                _ ->
                    ""
    in
        [ section [ class "tick_display" ]
            [ form [ class "search", disabled True ]
                [ input [ placeholder "계정명,퍼블릭키 검색하기", type_ "search", onInput InputSearch, onEnter (CheckSearchQuery header.searchInput) ]
                    []
                , button [ class "search button", type_ "button", onClick (CheckSearchQuery (header.searchInput)) ]
                    [ text "검색하기" ]
                ]
            , ul [ class "price" ]
                [ li []
                    [ text "이오스 시세                           "
                    , span [ attribute "data-before" "lower" ]
                        [ text "1.000 EOS                           " ]
                    ]
                , li []
                    [ text "RAM 가격                            "
                    , span [ attribute "data-before" "higher" ]
                        [ text "1.000 EOS                           " ]
                    ]
                ]
            ]
        , newContentHtml
        , Html.map NotificationMessage
            (Notification.view
                notification
                notificationParameter
                language
            )
        ]


onEnter : Message -> Attribute Message
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg
            else
                JD.fail "not ENTER"
    in
        on "keydown" (JD.andThen isEnter keyCode)



-- UPDATE


update : Message -> Model -> Flags -> Wallet -> ( Model, Cmd Message )
update message ({ page, notification, header } as model) flags { account } =
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
                ( newPage, subCmd ) =
                    Created.update subMessage subModel
            in
                ( { model | page = newPage |> CreatedPage }, Cmd.map CreatedMessage subCmd )

        ( CreateMessage subMessage, CreatePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Create.update subMessage subModel flags
            in
                ( { model | page = newPage |> CreatePage }, Cmd.map CreateMessage subCmd )

        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Search.update subMessage subModel
            in
                ( { model | page = newPage |> SearchPage }, Cmd.map SearchMessage subCmd )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Transfer.update subMessage subModel account
            in
                ( { model | page = newPage |> TransferPage }, Cmd.map TransferMessage subCmd )

        ( VotingMessage subMessage, VotingPage subModel ) ->
            let
                newPage =
                    Voting.update subMessage subModel
            in
                ( { model | page = newPage |> VotingPage }, Cmd.none )

        ( IndexMessage (Index.ChangeUrl url), _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdatePushActionResponse resp, _ ) ->
            ( { model
                | notification =
                    { content = resp |> decodePushActionResponse
                    , open = True
                    }
              }
            , Cmd.none
            )

        ( OnLocationChange location, _ ) ->
            let
                ( newPage, cmd ) =
                    getPage location
            in
                ( { model | page = newPage }, cmd )

        ( InputSearch value, _ ) ->
            ( { model | header = { header | searchInput = value } }, Cmd.none )

        ( CheckSearchQuery query, _ ) ->
            let
                parsedQuery =
                    parseQuery query

                newCmd =
                    case parsedQuery of
                        Ok AccountQuery ->
                            Navigation.newUrl ("/search?query=" ++ query)

                        Ok PublicKeyQuery ->
                            Navigation.newUrl ("/searchkey?query=" ++ query)

                        Err _ ->
                            Cmd.none
            in
                ( model, newCmd )

        ( NotificationMessage Notification.CloseNotification, _ ) ->
            ( { model
                | notification =
                    { notification | open = False }
              }
            , Cmd.none
            )

        ( _, _ ) ->
            ( model, Cmd.none )


parseQuery : String -> Result String Query
parseQuery query =
    -- EOS account's length is less than 12 letters
    -- EOS public key's length is 53 letters
    if isAccount query then
        Ok AccountQuery
    else if isPublicKey query then
        Ok PublicKeyQuery
    else
        Err "invalid input"


isAccount : String -> Bool
isAccount query =
    contains (regex "^[a-z.1-5]{1,12}$") query


isPublicKey : String -> Bool
isPublicKey query =
    contains (regex "^EOS[\\w]{50}$") query



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Sub.map CreateKeysMessage CreateKeys.subscriptions
        , Port.receivePushActionResponse UpdatePushActionResponse
        ]



-- Utility functions


getPage : Location -> ( Page, Cmd Message )
getPage location =
    let
        route =
            location |> parseLocation
    in
        case route of
            ConfirmEmailRoute ->
                ( ConfirmEmailPage ConfirmEmail.initModel, Cmd.none )

            EmailConfirmedRoute confirmToken email ->
                ( EmailConfirmedPage (EmailConfirmed.initModel confirmToken email), Cmd.none )

            EmailConfirmFailureRoute ->
                ( EmailConfirmFailurePage EmailConfirmFailure.initModel, Cmd.none )

            CreateKeysRoute confirmToken ->
                let
                    createKeysModel =
                        CreateKeys.initModel confirmToken

                    ( newCreateKeysModel, subCmd ) =
                        CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                    newPage =
                        CreateKeysPage newCreateKeysModel

                    cmd =
                        Cmd.map CreateKeysMessage subCmd
                in
                    ( newPage, cmd )

            CreatedRoute ->
                ( CreatedPage Created.initModel, Cmd.none )

            CreateRoute confirmToken pubkey ->
                ( CreatePage (Create.initModel confirmToken pubkey), Cmd.none )

            SearchRoute query ->
                let
                    initCmd =
                        case query of
                            Just str ->
                                Search.initCmd str

                            Nothing ->
                                Cmd.none
                in
                    ( SearchPage Search.initModel, Cmd.map SearchMessage initCmd )

            SearchKeyRoute query ->
                let
                    initCmd =
                        case query of
                            Just str ->
                                SearchKey.initCmd str

                            Nothing ->
                                Cmd.none
                in
                    ( SearchKeyPage SearchKey.initModel, Cmd.none )

            VotingRoute ->
                ( VotingPage Voting.initModel, Cmd.none )

            TransferRoute ->
                ( TransferPage Transfer.initModel, Cmd.none )

            IndexRoute ->
                ( IndexPage, Cmd.none )

            NotFoundRoute ->
                ( NotFoundPage, Cmd.none )
