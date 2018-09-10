module Component.Main.MainComponent exposing
    ( AccountQuery
    , Header
    , Message(..)
    , Model
    , Page(..)
    , PublicKeyQuery
    , Query(..)
    , getPage
    , initCmd
    , initModel
    , pageCmd
    , parseQuery
    , subscriptions
    , update
    , updateCmd
    , view
    )

import Component.Main.Page.Index as Index
import Component.Main.Page.NotFound as NotFound
import Component.Main.Page.Rammarket as Rammarket
import Component.Main.Page.Resource as Resource
import Component.Main.Page.Search as Search
import Component.Main.Page.SearchKey as SearchKey
import Component.Main.Page.Transfer as Transfer
import Component.Main.Page.Voting as Voting
import Component.Main.Sidebar as Sidebar
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , footer
        , form
        , h1
        , input
        , li
        , nav
        , section
        , span
        , text
        , ul
        )
import Html.Attributes
    exposing
        ( attribute
        , class
        , href
        , id
        , placeholder
        , rel
        , style
        , type_
        )
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Navigation exposing (Location)
import Port
import Route exposing (Route(..), parseLocation)
import Translation exposing (I18n(..), Language(..), translate)
import Util.Formatter exposing (eosStringToFloat)
import Util.Validation exposing (isAccount, isPublicKey)
import Util.WalletDecoder exposing (PushActionResponse, Wallet, decodePushActionResponse)
import View.Notification as Notification



-- MODEL


type Page
    = IndexPage
    | SearchPage Search.Model
    | SearchKeyPage SearchKey.Model
    | TransferPage Transfer.Model
    | ResourcePage Resource.Model
    | VotingPage Voting.Model
    | RammarketPage
    | NotFoundPage


type alias Header =
    { searchInput : String
    , eosPrice : Int
    , ramPrice : Int
    , errMessage : String
    , language : Language
    }


type alias Model =
    { page : Page
    , notification : Notification.Model
    , header : Header
    , sidebar : Sidebar.Model
    }


initModel : Location -> Model
initModel location =
    { page = location |> getPage
    , notification = Notification.initModel
    , header =
        { searchInput = ""
        , eosPrice = 0
        , ramPrice = 0
        , errMessage = ""
        , language = Korean
        }
    , sidebar = Sidebar.initModel
    }



-- MESSAGE


type Message
    = SearchMessage Search.Message
    | SearchKeyMessage SearchKey.Message
    | VotingMessage Voting.Message
    | TransferMessage Transfer.Message
    | ResourceMessage Resource.Message
    | IndexMessage Index.Message
    | InputSearch String
    | UpdatePushActionResponse PushActionResponse
    | CheckSearchQuery String
    | OnLocationChange Location Bool
    | NotificationMessage Notification.Message
    | SidebarMessage Sidebar.Message
    | ChangeUrl String
    | UpdateLanguage Language


type Query
    = AccountQuery
    | PublicKeyQuery


type alias AccountQuery =
    String


type alias PublicKeyQuery =
    String


initCmd : Model -> Location -> Cmd Message
initCmd { page } location =
    Cmd.batch
        [ pageCmd page location
        , Cmd.map SidebarMessage Sidebar.initCmd
        ]


updateCmd : Model -> Location -> Cmd Message
updateCmd { page } location =
    pageCmd page location


pageCmd : Page -> Location -> Cmd Message
pageCmd page location =
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
                            Search.initCmd str (Search.initModel str)

                        Nothing ->
                            Cmd.none
            in
            Cmd.map SearchMessage subInitCmd

        SearchKeyRoute query ->
            let
                subInitCmd =
                    case query of
                        Just str ->
                            SearchKey.initCmd str

                        Nothing ->
                            Cmd.none
            in
            Cmd.map SearchKeyMessage subInitCmd

        RammarketRoute ->
            Rammarket.initCmd

        _ ->
            Cmd.none



-- VIEW


view : Model -> Html Message
view { page, header, notification, sidebar } =
    let
        { language } =
            header

        newContentHtml =
            case page of
                SearchPage subModel ->
                    Html.map SearchMessage (Search.view language subModel)

                SearchKeyPage subModel ->
                    Html.map SearchKeyMessage (SearchKey.view language subModel)

                VotingPage subModel ->
                    Html.map VotingMessage (Voting.view language subModel)

                TransferPage subModel ->
                    Html.map TransferMessage
                        (Transfer.view
                            language
                            subModel
                            sidebar.account.coreLiquidBalance
                        )

                ResourcePage subModel ->
                    Html.map ResourceMessage
                        (Resource.view
                            language
                            subModel
                            sidebar.account
                        )

                IndexPage ->
                    Html.map IndexMessage (Index.view language)

                RammarketPage ->
                    Rammarket.view language

                _ ->
                    NotFound.view language

        getLanguageClass lang =
            if lang == language then
                class "selected"

            else
                class ""

        sidebarButtonClass =
            if sidebar.fold then
                class "toggle dashboard shrink"

            else
                class "toggle dashboard"

        headerView =
            Html.header []
                [ h1 []
                    [ a [ onClick (ChangeUrl "/") ] [ text "eoshub" ]
                    ]
                , div [ class "language" ]
                    [ button
                        [ type_ "button"
                        , getLanguageClass Korean
                        , attribute "data-lang" "ko"
                        , onClick (UpdateLanguage Korean)
                        ]
                        [ text "한글" ]
                    , button
                        [ type_ "button"
                        , getLanguageClass English
                        , attribute "data-lang" "en"
                        , onClick (UpdateLanguage English)
                        ]
                        [ text "ENG" ]
                    , button
                        [ type_ "button"
                        , getLanguageClass Chinese
                        , attribute "data-lang" "cn"
                        , onClick (UpdateLanguage Chinese)
                        ]
                        [ text "中文" ]
                    ]
                , form [ onSubmit (CheckSearchQuery header.searchInput) ]
                    [ input [ placeholder (translate language SearchDescribe), type_ "text", onInput InputSearch ]
                        []
                    , button [ type_ "button", onClick (CheckSearchQuery header.searchInput) ]
                        [ text (translate language Translation.Search) ]
                    ]
                ]

        navigationView =
            nav []
                [ ul []
                    [ li
                        []
                        [ button
                            [ type_ "button"
                            , sidebarButtonClass
                            , id "openAside"
                            , onClick (SidebarMessage Sidebar.ToggleSidebar)
                            ]
                            [ text (translate language Translation.OpenCloseSidebar) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.OpenCloseSidebar)
                            ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class "resource"
                            , onClick (ChangeUrl "/resource")
                            ]
                            [ text "리소스 관리" ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text "리소스 관리" ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class "transfer"
                            , onClick (ChangeUrl "/transfer")
                            ]
                            [ text (translate language Translation.Transfer) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.Transfer)
                            ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class "ram_market"
                            , onClick (ChangeUrl "/rammarket")
                            ]
                            [ text (translate language Translation.RamMarket) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.RamMarket)
                            ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class "vote"
                            , onClick (ChangeUrl "/voting")
                            ]
                            [ text (translate language Translation.Vote) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.Vote)
                            ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class "dapps"
                            , onClick (ChangeUrl "/dapps")
                            ]
                            [ text "Dapps" ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text "Dapps"
                            ]
                        ]
                    ]
                ]

        footerView =
            footer []
                [ div [ class "sns area" ]
                    [ a [ href "#", class "sns medium button" ] [ text "Go to Medium" ]
                    , a [ href "#", class "sns twitter button" ] [ text "Go to Twitter" ]
                    , a [ href "#", class "sns telegram button" ] [ text "Go to Telegram" ]
                    ]
                ]
    in
    div []
        [ headerView
        , navigationView
        , section [ class "content" ]
            [ Html.map SidebarMessage (Sidebar.view sidebar language)
            , newContentHtml
            , Html.map NotificationMessage
                (Notification.view
                    notification
                    language
                )
            ]
        , footerView
        ]



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message ({ page, notification, header, sidebar } as model) =
    case ( message, page ) of
        ( SearchMessage subMessage, SearchPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Search.update subMessage subModel
            in
            ( { model | page = newPage |> SearchPage }, Cmd.map SearchMessage subCmd )

        ( SearchKeyMessage subMessage, SearchKeyPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    SearchKey.update subMessage subModel
            in
            ( { model | page = newPage |> SearchKeyPage }, Cmd.map SearchKeyMessage subCmd )

        ( TransferMessage subMessage, TransferPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Transfer.update
                        subMessage
                        subModel
                        sidebar.wallet.account
                        (eosStringToFloat sidebar.account.coreLiquidBalance)
            in
            ( { model | page = newPage |> TransferPage }, Cmd.map TransferMessage subCmd )

        ( ResourceMessage subMessage, ResourcePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Resource.update
                        subMessage
                        subModel
                        sidebar.account
            in
            ( { model | page = newPage |> ResourcePage }, Cmd.map ResourceMessage subCmd )

        ( VotingMessage subMessage, VotingPage subModel ) ->
            let
                newPage =
                    Voting.update subMessage subModel
            in
            ( { model | page = newPage |> VotingPage }, Cmd.none )

        ( IndexMessage (Index.ChangeUrl url), _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdatePushActionResponse resp, _ ) ->
            let
                notificationParameter =
                    case page of
                        TransferPage { transfer } ->
                            transfer.to

                        _ ->
                            ""
            in
            ( { model
                | notification =
                    { content = decodePushActionResponse resp notificationParameter
                    , open = True
                    }
              }
            , Cmd.none
            )

        ( OnLocationChange location newComponent, _ ) ->
            let
                newPage =
                    getPage location

                cmd =
                    if newComponent then
                        initCmd model location

                    else
                        updateCmd model location
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

        ( SidebarMessage sidebarMessage, _ ) ->
            let
                ( newSidebar, newCmd ) =
                    Sidebar.update sidebarMessage sidebar
            in
            ( { model | sidebar = newSidebar }, Cmd.map SidebarMessage newCmd )

        ( ChangeUrl url, _ ) ->
            ( model, Navigation.newUrl url )

        ( UpdateLanguage language, _ ) ->
            ( { model | header = { header | language = language } }, Cmd.none )

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
subscriptions { sidebar } =
    Sub.batch
        [ Port.receivePushActionResponse UpdatePushActionResponse
        , Sub.map SidebarMessage (Sidebar.subscriptions sidebar)
        ]



-- Utility functions


getPage : Location -> Page
getPage location =
    let
        route =
            location |> parseLocation
    in
    case route of
        SearchRoute query ->
            case query of
                Just str ->
                    SearchPage (Search.initModel str)

                Nothing ->
                    -- it needs no result page. it shows NotFoundPage temporarily
                    NotFoundPage

        SearchKeyRoute query ->
            case query of
                Just str ->
                    SearchKeyPage (SearchKey.initModel str)

                Nothing ->
                    -- it needs no result page. it shows NotFoundPage temporarily
                    NotFoundPage

        VotingRoute ->
            VotingPage Voting.initModel

        TransferRoute ->
            TransferPage Transfer.initModel

        ResourceRoute ->
            ResourcePage Resource.initModel

        IndexRoute ->
            IndexPage

        RammarketRoute ->
            RammarketPage

        NotFoundRoute ->
            NotFoundPage

        _ ->
            NotFoundPage
