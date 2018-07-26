module Test.Component.Account.AccountComponent exposing (..)

import Expect
import Navigation exposing (Location)
import Component.Account.AccountComponent exposing (..)
import Component.Account.Page.ConfirmEmail as ConfirmEmail
import Component.Account.Page.Create as Create
import Component.Account.Page.CreateKeys as CreateKeys
import Component.Account.Page.Created as Created
import Component.Account.Page.EmailConfirmFailure as EmailConfirmFailure
import Component.Account.Page.EmailConfirmed as EmailConfirmed
import Test exposing (..)
import Route


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
    in
        describe "Page module"
            [ describe "getPage"
                [ test "ConfirmEmailRoute" <|
                    \() -> Expect.equal (ConfirmEmailPage ConfirmEmail.initModel) (getPage Route.ConfirmEmailRoute)
                , test "EmailConfirmedRoute" <|
                    \() ->
                        let
                            email =
                                Just "test@chain.partners"
                        in
                            Expect.equal (EmailConfirmedPage (EmailConfirmed.initModel email)) (getPage (Route.EmailConfirmedRoute confirmToken email))
                , test "EmailConfirmFailureRoute" <|
                    \() -> Expect.equal (EmailConfirmFailurePage EmailConfirmFailure.initModel) (getPage Route.EmailConfirmFailureRoute)
                , test "CreateKeysRoute" <|
                    \() ->
                        let
                            createKeysModel =
                                CreateKeys.initModel

                            ( newCreateKeysModel, subCmd ) =
                                CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                            expectedPage =
                                CreateKeysPage newCreateKeysModel
                        in
                            Expect.equal expectedPage (getPage Route.CreateKeysRoute)
                , test "CreatedRoute" <|
                    \() -> Expect.equal (CreatedPage Created.initModel) (getPage Route.CreatedRoute)
                , test "CreateRoute" <|
                    \() ->
                        let
                            pubkey =
                                "testpubkey"
                        in
                            Expect.equal (CreatePage (Create.initModel pubkey)) (getPage (Route.CreateRoute pubkey))
                , test "NotFoundRoute" <|
                    \() -> Expect.equal NotFoundPage (getPage Route.NotFoundRoute)
                ]
            , describe "initCmd"
                [ test "CreateKeysRoute" <|
                    \() ->
                        let
                            createKeysModel =
                                CreateKeys.initModel

                            ( newCreateKeysModel, subCmd ) =
                                CreateKeys.update CreateKeys.GenerateKeys createKeysModel

                            expectedPage =
                                CreateKeysPage newCreateKeysModel

                            expectedCmd =
                                Cmd.map CreateKeysMessage subCmd

                            model =
                                { page = expectedPage
                                , confirmToken = confirmToken
                                }
                        in
                            Expect.equal expectedCmd (initCmd model)
                ]
            ]
