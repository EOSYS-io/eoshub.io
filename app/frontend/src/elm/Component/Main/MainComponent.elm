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

import Component.Main.Page.ChangeKey as ChangeKey
import Component.Main.Page.Index as Index
import Component.Main.Page.NewAccount as NewAccount
import Component.Main.Page.NotFound as NotFound
import Component.Main.Page.Rammarket as Rammarket
import Component.Main.Page.Resource as Resource
import Component.Main.Page.Search as Search
import Component.Main.Page.SearchKey as SearchKey
import Component.Main.Page.Transfer as Transfer
import Component.Main.Page.Vote as Vote
import Component.Main.Sidebar as Sidebar
import Data.Account exposing (Account, defaultAccount)
import Data.Common exposing (ApplicationState, initApplicationState)
import Data.Json exposing (Product)
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
        , target
        , type_
        )
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Navigation exposing (Location)
import Port
import Process
import Route exposing (Route(..), parseLocation)
import Set
import Task
import Time
import Translation exposing (I18n(..), Language(..), translate)
import Util.Constant exposing (eosysProxyAccount)
import Util.Flags exposing (Flags)
import Util.Formatter exposing (assetToFloat)
import Util.HttpRequest exposing (getEosAccountProduct)
import Util.Validation exposing (isAccount, isPublicKey)
import Util.WalletDecoder exposing (PushActionResponse, decodePushActionResponse)
import View.Notification as Notification



-- MODEL


type Page
    = IndexPage Index.Model
    | SearchPage Search.Model
    | SearchKeyPage SearchKey.Model
    | TransferPage Transfer.Model
    | ResourcePage Resource.Model
    | VotePage Vote.Model
    | RammarketPage Rammarket.Model
    | NotFoundPage
    | ChangeKeyPage ChangeKey.Model
    | NewAccountPage NewAccount.Model


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
    , applicationState : ApplicationState
    }


initModel : Location -> Model
initModel location =
    { page = location |> getPage defaultAccount
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
    , applicationState = initApplicationState
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
    | ChangeKeyMessage ChangeKey.Message
    | NewAccountMessage NewAccount.Message
    | InputSearch String
    | UpdatePushActionResponse PushActionResponse
    | CheckSearchQuery String
    | OnLocationChange Location Bool
    | NotificationMessage Notification.Message
    | SidebarMessage Sidebar.Message
    | ChangeUrl String
    | UpdateLanguage Language
    | InitLocale String
    | OnFetchProduct (Result Http.Error Product)


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
        , Cmd.map SidebarMessage
            (Sidebar.initCmd flags)
        , Port.checkLocale ()
        , getEosAccountProduct flags Translation.Korean
            |> Http.send OnFetchProduct
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

        IndexRoute ->
            Cmd.map IndexMessage Index.initCmd

        _ ->
            Cmd.none



-- VIEW


view : Model -> Html Message
view { page, header, notification, sidebar, selectedNav, applicationState } =
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
                    Html.map VoteMessage
                        (Vote.view
                            language
                            subModel
                            sidebar.account
                        )

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

                IndexPage subModel ->
                    Html.map IndexMessage (Index.view subModel language applicationState)

                RammarketPage subModel ->
                    Html.map RammarketMessage (Rammarket.view language subModel sidebar.account)

                ChangeKeyPage subModel ->
                    Html.map ChangeKeyMessage (ChangeKey.view language subModel sidebar.wallet)

                NewAccountPage subModel ->
                    Html.map NewAccountMessage (NewAccount.view language subModel sidebar.account)

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
                            [ text "CPU / NET" ]
                        , span [ class "tooltip", attribute "aria-hidden" "true" ]
                            [ text "CPU / NET" ]
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
                    [ a
                        [ href "https://medium.com/eosys", class "sns medium button", target "_blank" ]
                        [ text "Go to Medium" ]
                    , a
                        [ href "https://twitter.com/EOSYS_IO", class "sns twitter button", target "_blank" ]
                        [ text "Go to Twitter" ]
                    , a [ href (translate language GoToTelegramLink), class "sns telegram button" ]
                        [ text "Go to Telegram" ]
                    ]
                ]
    in
    div []
        [ headerView
        , navigationView
        , section [ class "content" ]
            [ Html.map SidebarMessage (Sidebar.view sidebar language applicationState.eventActivation)
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
update message ({ page, notification, header, sidebar, applicationState } as model) flags =
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

        ( IndexMessage subMessage, IndexPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Index.update subMessage subModel
            in
            ( { model | page = newPage |> IndexPage }, Cmd.map IndexMessage subCmd )

        ( RammarketMessage subMessage, RammarketPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    Rammarket.update subMessage subModel sidebar.account
            in
            ( { model | page = newPage |> RammarketPage }, Cmd.map RammarketMessage subCmd )

        ( ChangeKeyMessage subMessage, ChangeKeyPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    ChangeKey.update subMessage subModel sidebar.wallet
            in
            ( { model | page = newPage |> ChangeKeyPage }, Cmd.map ChangeKeyMessage subCmd )

        ( NewAccountMessage subMessage, NewAccountPage subModel ) ->
            let
                ( newPage, subCmd ) =
                    NewAccount.update subMessage subModel sidebar.account
            in
            ( { model | page = newPage |> NewAccountPage }, Cmd.map NewAccountMessage subCmd )

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

                        RammarketPage { isBuyTab, buyModel } ->
                            if isBuyTab then
                                if buyModel.proxyBuy then
                                    buyModel.params.receiver

                                else
                                    sidebar.account.accountName

                            else
                                ""

                        VotePage { tab } ->
                            case tab of
                                Vote.VoteTab ->
                                    ""

                                Vote.ProxyVoteTab ->
                                    eosysProxyAccount

                        _ ->
                            ""

                defer time msg =
                    Process.sleep time |> Task.perform (\_ -> msg)

                -- Wait one block confirmation time for accuracy.
                accountRefreshCmd =
                    defer (500 * Time.millisecond)
                        (Sidebar.UpdateState sidebar.state)

                refreshCmd =
                    case page of
                        TransferPage { currentSymbol } ->
                            case currentSymbol of
                                "EOS" ->
                                    Cmd.map SidebarMessage accountRefreshCmd

                                _ ->
                                    -- Wait one block confirmation time for accuracy.
                                    Cmd.map TransferMessage
                                        (defer (500 * Time.millisecond) Transfer.UpdateToken)

                        _ ->
                            Cmd.map SidebarMessage accountRefreshCmd
            in
            ( { model
                | notification =
                    { content = decodePushActionResponse resp notificationParameter
                    , open = True
                    }
              }
            , Cmd.batch [ refreshCmd ]
            )

        ( OnLocationChange location newComponent, _ ) ->
            let
                newPage =
                    getPage sidebar.account location

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

        ( NotificationMessage Notification.MoveToAccountPage, _ ) ->
            ( { model | notification = { notification | open = False } }
            , Navigation.newUrl ("/search?query=" ++ sidebar.account.accountName)
            )

        ( NotificationMessage Notification.MoveToCpunetPage, _ ) ->
            ( { model | notification = { notification | open = False } }
            , Navigation.newUrl "/resource"
            )

        ( SidebarMessage (Sidebar.OnFetchAccount (Ok ({ voterInfo } as data))), VotePage subModel ) ->
            -- This is an exceptional case. The model on vote page needed to be updated
            -- when an update of the account in sidebar occurs.
            let
                newSidebar =
                    { sidebar | account = data }

                newVoteModel =
                    { subModel | producerNamesToVote = Set.fromList voterInfo.producers }
            in
            ( { model | sidebar = newSidebar, page = VotePage newVoteModel }, Cmd.none )

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

        ( InitLocale localeString, _ ) ->
            let
                locale =
                    localeString |> String.split "-" |> List.head |> Maybe.withDefault "en"

                language =
                    case locale of
                        "ko" ->
                            Korean

                        "zh" ->
                            Chinese

                        _ ->
                            English
            in
            update (UpdateLanguage language) model flags

        ( OnFetchProduct (Ok { eventActivation }), _ ) ->
            ( { model
                | applicationState =
                    { applicationState
                        | eventActivation = eventActivation
                    }
              }
            , Cmd.none
            )

        ( OnFetchProduct (Err _), _ ) ->
            ( model, Cmd.none )

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
subscriptions { page } =
    Sub.batch
        [ Port.receivePushActionResponse UpdatePushActionResponse
        , Sub.map SidebarMessage Sidebar.subscriptions
        , case page of
            IndexPage subModel ->
                Sub.map IndexMessage (Index.subscriptions subModel)

            RammarketPage _ ->
                Sub.map RammarketMessage Rammarket.subscriptions

            VotePage _ ->
                Sub.map VoteMessage Vote.subscriptions

            _ ->
                Sub.none
        , Port.receiveLocale InitLocale
        ]



-- Utility functions


getPage : Account -> Location -> Page
getPage account location =
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
            VotePage (Vote.initModel account)

        TransferRoute ->
            TransferPage Transfer.initModel

        ResourceRoute ->
            ResourcePage Resource.initModel

        IndexRoute ->
            IndexPage Index.initModel

        RammarketRoute ->
            RammarketPage Rammarket.initModel

        NotFoundRoute ->
            NotFoundPage

        ChangeKeyRoute ->
            ChangeKeyPage ChangeKey.initModel

        NewAccountRoute ->
            NewAccountPage NewAccount.initModel

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
