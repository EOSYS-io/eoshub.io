module Component.Main.MainComponent exposing
    ( AccountQuery
    , Header
    , Message(..)
    , Model
    , Page(..)
    , PublicKeyQuery
    , Query(..)
    , SelectedNav(..)
    , getNavClass
    , getPage
    , getPageNav
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
import Component.Main.Page.Vote as Vote
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
import Util.Flags exposing (Flags)
import Util.Formatter exposing (assetToFloat)
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
    | VotePage Vote.Model
    | RammarketPage Rammarket.Model
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
    , selectedNav : SelectedNav
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
    , selectedNav = None
    }



-- MESSAGE


type Message
    = SearchMessage Search.Message
    | SearchKeyMessage SearchKey.Message
    | VoteMessage Vote.Message
    | TransferMessage Transfer.Message
    | ResourceMessage Resource.Message
    | IndexMessage Index.Message
    | RammarketMessage Rammarket.Message
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


type SelectedNav
    = TransferNav
    | VoteNav
    | ResourceNav
    | RammarketNav
    | None


initCmd : Location -> Flags -> Cmd Message
initCmd location flags =
    Cmd.batch
        [ pageCmd location flags
        , Cmd.map SidebarMessage Sidebar.initCmd
        ]


updateCmd : Location -> Flags -> Cmd Message
updateCmd location flags =
    pageCmd location flags


pageCmd : Location -> Flags -> Cmd Message
pageCmd location flags =
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
            Cmd.map RammarketMessage Rammarket.initCmd

        VoteRoute ->
            Cmd.map VoteMessage (Vote.initCmd flags)

        _ ->
            Cmd.none



-- VIEW


view : Model -> Html Message
view { page, header, notification, sidebar, selectedNav } =
    let
        { language } =
            header

        newContentHtml =
            case page of
                SearchPage subModel ->
                    Html.map SearchMessage (Search.view language subModel)

                SearchKeyPage subModel ->
                    Html.map SearchKeyMessage (SearchKey.view language subModel)

                VotePage subModel ->
                    Html.map VoteMessage (Vote.view language subModel)

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

                RammarketPage subModel ->
                    Html.map RammarketMessage (Rammarket.view language subModel sidebar.account)

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
                            , class ("transfer" ++ getNavClass selectedNav TransferNav)
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
                            , class ("vote" ++ getNavClass selectedNav VoteNav)
                            , onClick (ChangeUrl "/vote")
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
                            , class ("resource" ++ getNavClass selectedNav ResourceNav)
                            , onClick (ChangeUrl "/resource")
                            ]
                            [ text (translate language Translation.ManageResource) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.ManageResource) ]
                        ]
                    , li
                        []
                        [ a
                            [ rel "nofollow"
                            , class ("ram_market" ++ getNavClass selectedNav RammarketNav)
                            , onClick (ChangeUrl "/rammarket")
                            ]
                            [ text (translate language Translation.RamMarket) ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text (translate language Translation.RamMarket)
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


update : Message -> Model -> Flags -> ( Model, Cmd Message )
update message ({ page, notification, header, sidebar } as model) flags =
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
                        (assetToFloat sidebar.account.coreLiquidBalance)
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

        ( VoteMessage subMessage, VotePage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Vote.update subMessage subModel flags sidebar.account
            in
            ( { model | page = newPage |> VotePage }, Cmd.map VoteMessage subCmd )

        ( IndexMessage (Index.ChangeUrl url), _ ) ->
            ( model, Navigation.newUrl url )

        ( RammarketMessage subMessage, RammarketPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Rammarket.update subMessage subModel sidebar.account
            in
            ( { model | page = newPage |> RammarketPage }, Cmd.map RammarketMessage subCmd )

        ( UpdatePushActionResponse resp, _ ) ->
            let
                notificationParameter =
                    case page of
                        TransferPage { transfer } ->
                            transfer.to

                        ResourcePage { tab } ->
                            case tab of
                                Resource.Stake { delegatebw } ->
                                    delegatebw.receiver

                                Resource.Unstake { undelegatebw } ->
                                    undelegatebw.receiver

                                Resource.Delegate { delegatebw } ->
                                    delegatebw.receiver

                                Resource.Undelegate { undelegatebw } ->
                                    undelegatebw.receiver

                        _ ->
                            ""

                ( newSidebar, accoutRefreshCmd ) =
                    Sidebar.update (Sidebar.UpdateState sidebar.state) sidebar
            in
            ( { model
                | notification =
                    { content = decodePushActionResponse resp notificationParameter
                    , open = True
                    }
                , sidebar = newSidebar
              }
            , Cmd.map SidebarMessage accoutRefreshCmd
            )

        ( OnLocationChange location newComponent, _ ) ->
            let
                newPage =
                    getPage location

                newSelectedNav =
                    getPageNav location.pathname

                cmd =
                    if newComponent then
                        initCmd location flags

                    else
                        updateCmd location flags
            in
            ( { model | page = newPage, selectedNav = newSelectedNav }, cmd )

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
subscriptions { sidebar, page } =
    Sub.batch
        [ Port.receivePushActionResponse UpdatePushActionResponse
        , Sub.map SidebarMessage Sidebar.subscriptions
        , case page of
            RammarketPage _ ->
                Sub.map RammarketMessage Rammarket.subscriptions

            VotePage _ ->
                Sub.map VoteMessage Vote.subscriptions

            _ ->
                Sub.none
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

        VoteRoute ->
            VotePage Vote.initModel

        TransferRoute ->
            TransferPage Transfer.initModel

        ResourceRoute ->
            ResourcePage Resource.initModel

        IndexRoute ->
            IndexPage

        RammarketRoute ->
            RammarketPage Rammarket.initModel

        NotFoundRoute ->
            NotFoundPage

        _ ->
            NotFoundPage


getPageNav : String -> SelectedNav
getPageNav pathname =
    case pathname of
        "/transfer" ->
            TransferNav

        "/vote" ->
            VoteNav

        "/resource" ->
            ResourceNav

        "/rammarket" ->
            RammarketNav

        _ ->
            None


getNavClass : SelectedNav -> SelectedNav -> String
getNavClass modelSelectedNav thisSelectedNav =
    if modelSelectedNav == thisSelectedNav then
        " viewing"

    else
        ""
