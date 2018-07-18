module Page exposing (..)

import ExternalMessage
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
import Page.Transfer as Transfer
import Page.Voting as Voting
import Port
import Route exposing (Route(..), parseLocation)
import Translation exposing (Language)
import Util.Flags exposing (Flags)
import Util.WalletDecoder exposing (ScatterResponse, decodeScatterResponse)
import View.Notification
import Http
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE
import Regex exposing (regex, contains)
import Data.Account exposing (Account, ResourceInEos, Resource, Refund, accountDecoder, keyAccountsDecoder)


-- MODEL


type Page
    = IndexPage
    | ConfirmEmailPage ConfirmEmail.Model
    | EmailConfirmedPage EmailConfirmed.Model
    | EmailConfirmFailurePage EmailConfirmFailure.Model
    | CreatedPage Created.Model
    | CreateKeysPage CreateKeys.Model
    | CreatePage Create.Model
    | SearchPage Account
    | TransferPage Transfer.Model
    | VotingPage Voting.Model
    | NotFoundPage


type alias Model =
    { page : Page
    , notification : View.Notification.Message
    , header : Header
    }


type alias Header =
    { searchInput : String
    , eosPrice : Int
    , ramPrice : Int
    , keyAccounts : List String
    , account : Account
    , errMessage : String
    }


initModel : Location -> Model
initModel location =
    { page = location |> getPage
    , notification = View.Notification.None
    , header =
        { searchInput = ""
        , eosPrice = 0
        , ramPrice = 0
        , keyAccounts = []
        , account =
            { account_name = ""
            , core_liquid_balance = "0 EOS"
            , ram_quota = 0
            , ram_usage = 0
            , net_limit =
                { used = 0, available = 0, max = 0 }
            , cpu_limit =
                { used = 0, available = 0, max = 0 }
            , total_resources =
                { net_weight = "0 EOS"
                , cpu_weight = "0 EOS"
                , ram_bytes = Just 0
                }
            , self_delegated_bandwidth =
                Just
                    { net_weight = "0 EOS"
                    , cpu_weight = "0 EOS"
                    , ram_bytes = Nothing
                    }
            , refund_request =
                Just
                    { owner = ""
                    , request_time = ""
                    , net_amount = ""
                    , cpu_amount = ""
                    }
            }
        , errMessage = ""
        }
    }


apiUrl : String
apiUrl =
    "https://rpc.eosys.io"



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
    | InputSearch String
    | GetSearchResult String
    | OnFetchAccount (Result Http.Error Account)
    | OnFetchKeyAccounts (Result Http.Error (List String))
    | OnLocationChange Location


type Query
    = AccountQuery
    | PublicKeyQuery


type alias AccountQuery =
    String


type alias PublicKeyQuery =
    String



-- VIEW


view : Language -> Model -> Html Message
view language { page, header } =
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
    in
        Html.div [ class "wrapper" ]
            [ div []
                [ section [ class "tick_display" ]
                    [ form [ class "search", disabled True ]
                        [ input [ placeholder "계정명,퍼블릭키 검색하기", type_ "search", onInput InputSearch, onEnter (GetSearchResult (header.searchInput)) ]
                            []
                        , button [ class "search button", type_ "button", onClick (GetSearchResult (header.searchInput)) ]
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
                ]
            , newContentHtml
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


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message ({ page, header } as model) flags =
    case ( message, page ) of
        ( ConfirmEmailMessage subMessage, ConfirmEmailPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    ConfirmEmail.update subMessage subModel flags
            in
                ( { model | page = newPage |> ConfirmEmailPage }, Cmd.map ConfirmEmailMessage subCmd )

        ( EmailConfirmedMessage subMessage, EmailConfirmedPage subModel ) ->
            let
                newPage =
                    EmailConfirmed.update subMessage subModel
            in
                ( { model | page = newPage |> EmailConfirmedPage }, Cmd.none )

        ( EmailConfirmFailureMessage subMessage, EmailConfirmFailurePage subModel ) ->
            let
                newPage =
                    EmailConfirmFailure.update subMessage subModel
            in
                ( { model | page = newPage |> EmailConfirmFailurePage }, Cmd.none )

        ( CreateKeysMessage subMessage, CreateKeysPage subModel ) ->
            let
                newPage =
                    CreateKeys.update subMessage subModel
            in
                ( { model | page = newPage |> CreateKeysPage }, Cmd.none )

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
            ( { model | page = location |> getPage }, Cmd.none )

        ( InputSearch value, _ ) ->
            ( { model | header = { header | searchInput = value } }, Cmd.none )

        ( GetSearchResult query, _ ) ->
            let
                parsedQuery =
                    (parseQuery query)

                newCmd =
                    case parsedQuery of
                        Ok AccountQuery ->
                            let
                                body =
                                    JE.object
                                        [ ( "account_name", JE.string query ) ]
                                        |> Http.jsonBody
                            in
                                post (getFullPath "/v1/chain/get_account") body accountDecoder |> (Http.send OnFetchAccount)

                        Ok PublicKeyQuery ->
                            let
                                body =
                                    JE.object
                                        [ ( "public_key", JE.string query ) ]
                                        |> Http.jsonBody
                            in
                                post (getFullPath "/v1/history/get_key_accounts") body keyAccountsDecoder |> (Http.send OnFetchKeyAccounts)

                        Err _ ->
                            Cmd.none
            in
                ( model, newCmd )

        ( OnFetchAccount (Ok data), _ ) ->
            let
                newPage =
                    SearchPage data
            in
                ( { model
                    | header = { header | account = data, errMessage = "success" }
                    , page = newPage
                  }
                , Navigation.newUrl "/search"
                )

        ( OnFetchAccount (Err error), _ ) ->
            ( { model | header = { header | errMessage = "invalid length" } }, Cmd.none )

        ( OnFetchKeyAccounts (Ok data), _ ) ->
            ( { model
                | header = { header | keyAccounts = data, errMessage = "success" }
              }
            , Cmd.none
            )

        ( OnFetchKeyAccounts (Err error), _ ) ->
            ( { model | header = { header | errMessage = "invalid length" } }, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


getFullPath : String -> String
getFullPath path =
    apiUrl ++ path


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


post : String -> Http.Body -> Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Message
subscriptions _ =
    Port.receiveScatterResponse UpdateScatterResponse



-- Utility functions


getPage : Location -> Page
getPage location =
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
                CreateKeysPage CreateKeys.initModel

            CreatedRoute ->
                CreatedPage Created.initModel

            CreateRoute confirmToken pubkey ->
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
