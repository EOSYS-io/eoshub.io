module Test.Component.Main.MainComponent exposing (location, tests)

import Component.Main.MainComponent exposing (..)
import Component.Main.Page.Search as Search
import Component.Main.Page.Transfer as Transfer
import Component.Main.Page.Vote as Vote
import Component.Main.Sidebar as Sidebar exposing (accountCmd)
import Expect
import Navigation exposing (Location)
import Test exposing (..)
import Translation exposing (I18n(CheckDetail, TransferSucceeded), Language(..))
import Util.WalletDecoder exposing (WalletStatus(Authenticated))
import View.Notification


location : Location
location =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = "/none"
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


tests : Test
tests =
    let
        wallet =
            { status = Authenticated
            , account = "account"
            , authority = "active"
            }

        flags =
            { node_env = "test" }
    in
    describe "Page module"
        [ describe "getPage"
            [ test "IndexRoute" <|
                \() -> Expect.equal IndexPage (getPage { location | pathname = "/" })
            , test "VoteRoute" <|
                \() -> Expect.equal (VotePage Vote.initModel) (getPage { location | pathname = "/vote" })
            , test "TransferRoute" <|
                \() -> Expect.equal (TransferPage Transfer.initModel) (getPage { location | pathname = "/transfer" })
            , test "SearchRoute" <|
                \() ->
                    Expect.equal (SearchPage (Search.initModel "123412341234")) (getPage { location | pathname = "/search", search = "?query=123412341234" })
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage location)
            ]
        , describe "getPageNav"
            [ test "/transfer" <|
                \() -> Expect.equal TransferNav (getPageNav "/transfer")
            , test "/vote" <|
                \() -> Expect.equal VoteNav (getPageNav "/vote")
            , test "/resource" <|
                \() -> Expect.equal ResourceNav (getPageNav "/resource")
            , test "/rammarket" <|
                \() ->
                    Expect.equal RammarketNav (getPageNav "/rammarket")
            , test "else" <|
                \() -> Expect.equal NothingNav (getPageNav "/search")
            ]
        , describe "getNavClass"
            [ test "equal" <|
                \() -> Expect.equal " viewing" (getNavClass TransferNav TransferNav)
            , test "not equal" <|
                \() -> Expect.equal "" (getNavClass TransferNav ResourceNav)
            ]
        , describe "update"
            [ test "UpdatePushActionResponse" <|
                \() ->
                    let
                        ({ notification, page, sidebar } as model) =
                            initModel { location | pathname = "/transfer" }

                        notificationParameter =
                            case page of
                                TransferPage { transfer } ->
                                    transfer.to

                                _ ->
                                    ""

                        expectedModel =
                            { model
                                | notification =
                                    { notification
                                        | content =
                                            View.Notification.Ok
                                                { message = TransferSucceeded notificationParameter
                                                , detail = CheckDetail
                                                }
                                        , open = True
                                    }
                            }

                        pushActionResponse =
                            { code = 200
                            , type_ = ""
                            , message = ""
                            , action = "transfer"
                            }

                        newCmd =
                            accountCmd sidebar.state wallet.account
                    in
                    Expect.equal
                        ( expectedModel, Cmd.map SidebarMessage newCmd )
                        (update (UpdatePushActionResponse pushActionResponse) model flags)
            , test "UpdateLanguage" <|
                \() ->
                    let
                        ({ header } as model) =
                            initModel location
                    in
                    Expect.equal
                        ( { model | header = { header | language = English } }, Cmd.none )
                        (update (UpdateLanguage English) model flags)
            , test "CloseNotification" <|
                \() ->
                    let
                        ({ notification } as model) =
                            initModel location

                        openedModel =
                            { model
                                | notification =
                                    { notification
                                        | open = True
                                    }
                            }

                        expectedModel =
                            { openedModel
                                | notification =
                                    { notification
                                        | open = False
                                    }
                            }
                    in
                    Expect.equal ( expectedModel, Cmd.none )
                        (update
                            (NotificationMessage View.Notification.CloseNotification)
                            openedModel
                            flags
                        )
            ]
        , describe "parseQuery"
            [ test "account" <|
                \() ->
                    Expect.equal (Ok AccountQuery) (parseQuery "123412341234")
            , test "public key" <|
                \() ->
                    Expect.equal (Ok PublicKeyQuery) (parseQuery "EOS5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "public key, does not start with 'EOS' " <|
                \() ->
                    Expect.equal (Err "invalid input") (parseQuery "eos5uxjV3FYZvwqyAM2StkFEvUvf43F7gSrZcBpunuuTxiYkKqb6d")
            , test "not both" <|
                \() ->
                    Expect.equal (Err "invalid input") (parseQuery "12345678901234567890")
            ]
        ]
