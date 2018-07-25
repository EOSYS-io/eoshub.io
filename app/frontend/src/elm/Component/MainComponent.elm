module Component.MainComponent exposing (..)

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
import View.Notification as Notification
import Util.Validation exposing (isAccount, isPublicKey)


-- MODEL


type Page
    = IndexPage
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


initModel : Location -> Model
initModel location =
    let
        page =
            getPage location
    in
        { page = page
        , notification = Notification.initModel
        , header =
            { searchInput = ""
            , eosPrice = 0
            , ramPrice = 0
            , errMessage = ""
            }
        }



-- MESSAGE


type Message
    = SearchMessage Search.Message
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


initCmd : Location -> Cmd Message
initCmd location =
    let
        route =
            location |> parseLocation
    in
        case route of
            SearchRoute query ->
                let
                    subInitCmd =
                        case query of
                            Just str ->
                                Search.initCmd str

                            Nothing ->
                                Cmd.none
                in
                    Cmd.map SearchMessage subInitCmd

            _ ->
                Cmd.none



-- VIEW


view : Language -> Model -> List (Html Message)
view language { page, header, notification } =
    let
        newContentHtml =
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


update : Message -> Model -> Wallet -> ( Model, Cmd Message )
update message ({ page, notification, header } as model) { account } =
    case ( message, page ) of
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
                newPage =
                    getPage location

                cmd =
                    initCmd location
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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Port.receivePushActionResponse UpdatePushActionResponse ]



-- Utility functions


getPage : Location -> Page
getPage location =
    let
        route =
            location |> parseLocation
    in
        case route of
            SearchRoute query ->
                SearchPage Search.initModel

            SearchKeyRoute query ->
                SearchKeyPage SearchKey.initModel

            VotingRoute ->
                VotingPage Voting.initModel

            TransferRoute ->
                TransferPage Transfer.initModel

            IndexRoute ->
                IndexPage

            NotFoundRoute ->
                NotFoundPage

            _ ->
                NotFoundPage
