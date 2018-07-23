module Test.AccountPageGroup exposing (..)

import Expect
import Navigation exposing (Location)
import AccountPageGroup exposing (..)
import Page.Account.ConfirmEmail as ConfirmEmail
import Page.Account.Create as Create
import Page.Account.CreateKeys as CreateKeys
import Page.Account.Created as Created
import Page.Account.EmailConfirmFailure as EmailConfirmFailure
import Page.Account.EmailConfirmed as EmailConfirmed
import Test exposing (..)
import Util.WalletDecoder exposing (WalletStatus(Authenticated))


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
                [ test "ConfirmEmailRoute" <|
                    \() -> Expect.equal ( ConfirmEmailPage ConfirmEmail.initModel ) (getPage { location | pathname = "/account/confirm_email" })
                , test "EmailConfirmedRoute" <|
                    \() ->
                        let
                            email =
                                Just "test@chain.partners"
                        in
                            Expect.equal ( EmailConfirmedPage (EmailConfirmed.initModel confirmToken email) ) (getPage { location | pathname = "/account/email_confirmed/testToken", search = "?email=test@chain.partners" })
                , test "EmailConfirmFailureRoute" <|
                    \() -> Expect.equal ( EmailConfirmFailurePage EmailConfirmFailure.initModel ) (getPage { location | pathname = "/account/email_confirm_failure" })
                , test "CreateKeysRoute" <|
                    \() ->
                        let
                            createKeysModel =
                                CreateKeys.initModel confirmToken

                            ( newCreateKeysModel, subCmd ) =
                                CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                            expectedPage =
                                CreateKeysPage newCreateKeysModel
                        in
                            Expect.equal expectedPage (getPage { location | pathname = "/account/create_keys/testToken" })
                , test "CreatedRoute" <|
                    \() -> Expect.equal ( CreatedPage Created.initModel ) (getPage { location | pathname = "/account/created" })
                , test "CreateRoute" <|
                    \() ->
                        let
                            pubkey =
                                "testpubkey"
                        in
                            Expect.equal ( CreatePage (Create.initModel confirmToken pubkey) ) (getPage { location | pathname = "/account/create/testToken/testpubkey" })
                , test "NotFoundRoute" <|
                    \() -> Expect.equal NotFoundPage (getPage location)
                ]
            , describe "initCmd"
                [ test "CreateKeysRoute" <|
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
                            Expect.equal expectedCmd (initCmd expectedPage)
                ]
            ]

