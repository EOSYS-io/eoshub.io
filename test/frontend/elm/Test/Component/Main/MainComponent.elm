module Test.Component.Main.MainComponent exposing (..)

import Expect
import Navigation exposing (Location)
import Component.Main.MainComponent exposing (..)
import Component.Main.Page.Search as Search
import Component.Main.Page.Transfer as Transfer
import Component.Main.Page.Voting as Voting
import Test exposing (..)
import Translation exposing (I18n(TransferSucceeded))
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
    in
        describe "Page module"
            [ describe "getPage"
                [ test "IndexRoute" <|
                    \() -> Expect.equal IndexPage (getPage { location | pathname = "/" })
                , test "VotingRoute" <|
                    \() -> Expect.equal (VotingPage Voting.initModel) (getPage { location | pathname = "/voting" })
                , test "TransferRoute" <|
                    \() -> Expect.equal (TransferPage Transfer.initModel) (getPage { location | pathname = "/transfer" })
                , test "SearchRoute" <|
                    \() ->
                        Expect.equal (SearchPage Search.initModel) (getPage { location | pathname = "/search", search = "?query=123412341234" })
                , test "NotFoundRoute" <|
                    \() -> Expect.equal NotFoundPage (getPage location)
                ]
            , describe "update"
                [ test "UpdatePushActionResponse" <|
                    \() ->
                        let
                            ({ notification } as model) =
                                initModel location

                            expectedModel =
                                { model
                                    | notification =
                                        { notification
                                            | content = View.Notification.Ok TransferSucceeded
                                            , open = True
                                        }
                                }

                            pushActionResponse =
                                { code = 200
                                , type_ = ""
                                , message = ""
                                , action = "transfer"
                                }
                        in
                            Expect.equal
                                ( expectedModel, Cmd.none )
                                (update (UpdatePushActionResponse pushActionResponse) model)
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