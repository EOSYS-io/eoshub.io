module Test.Page exposing (..)

import Expect
import Navigation exposing (Location)
import Page exposing (..)
import Page.Account.ConfirmEmail as ConfirmEmail
import Page.Account.Create as Create
import Page.Account.CreateKeys as CreateKeys
import Page.Account.Created as Created
import Page.Account.EmailConfirmFailure as EmailConfirmFailure
import Page.Account.EmailConfirmed as EmailConfirmed
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
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
        flags =
            { node_env = "test" }

        confirmToken =
            "testToken"

        wallet =
            { status = Authenticated
            , account = "account"
            , authority = "active"
            }
    in
        describe "Page module"
            [ describe "getPage"
                [ test "IndexRoute" <|
                    \() -> Expect.equal ( IndexPage, Cmd.none ) (getPage { location | pathname = "/" })
                , test "ConfirmEmailRoute" <|
                    \() -> Expect.equal ( ConfirmEmailPage ConfirmEmail.initModel, Cmd.none ) (getPage { location | pathname = "/account/confirm_email" })
                , test "EmailConfirmedRoute" <|
                    \() ->
                        let
                            email =
                                Just "test@chain.partners"
                        in
                            Expect.equal ( EmailConfirmedPage (EmailConfirmed.initModel confirmToken email), Cmd.none ) (getPage { location | pathname = "/account/email_confirmed/testToken", search = "?email=test@chain.partners" })
                , test "EmailConfirmFailureRoute" <|
                    \() -> Expect.equal ( EmailConfirmFailurePage EmailConfirmFailure.initModel, Cmd.none ) (getPage { location | pathname = "/account/email_confirm_failure" })
                , test "CreateKeysRoute" <|
                    \() ->
                        let
                            createKeysModel =
                                CreateKeys.initModel confirmToken

                            ( newCreateKeysModel, subCmd ) =
                                CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                            expectedPage =
                                CreateKeysPage newCreateKeysModel

                            expectedCmd =
                                Cmd.map CreateKeysMessage subCmd
                        in
                            Expect.equal ( expectedPage, expectedCmd ) (getPage { location | pathname = "/account/create_keys/testToken" })
                , test "CreatedRoute" <|
                    \() -> Expect.equal ( CreatedPage Created.initModel, Cmd.none ) (getPage { location | pathname = "/account/created" })
                , test "CreateRoute" <|
                    \() ->
                        let
                            pubkey =
                                "testpubkey"
                        in
                            Expect.equal ( CreatePage (Create.initModel confirmToken pubkey), Cmd.none ) (getPage { location | pathname = "/account/create/testToken/testpubkey" })
                , test "VotingRoute" <|
                    \() -> Expect.equal ( VotingPage Voting.initModel, Cmd.none ) (getPage { location | pathname = "/voting" })
                , test "TransferRoute" <|
                    \() -> Expect.equal ( TransferPage Transfer.initModel, Cmd.none ) (getPage { location | pathname = "/transfer" })
                , test "SearchRoute" <|
                    \() ->
                        Expect.equal (SearchPage Search.initModel) (Tuple.first (getPage { location | pathname = "/search", search = "?query=123412341234" }))
                , test "NotFoundRoute" <|
                    \() -> Expect.equal ( NotFoundPage, Cmd.none ) (getPage location)
                ]
            , describe "update"
                [ test "UpdatePushActionResponse" <|
                    \() ->
                        let
                            ( { notification } as model, cmd ) =
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
                                (update (UpdatePushActionResponse pushActionResponse) model flags wallet)
                , test "CloseNotification" <|
                    \() ->
                        let
                            ( { notification } as model, cmd ) =
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
                                    wallet
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
