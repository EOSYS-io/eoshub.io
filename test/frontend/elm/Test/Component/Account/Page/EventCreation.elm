module Test.Component.Account.Page.EventCreation exposing (model, tests)

import Component.Account.Page.EventCreation exposing (..)
import Expect
import Http
import Test exposing (..)
import Translation exposing (I18n(EmptyMessage))
import View.Notification as Notification


model : Model
model =
    { accountName = "testtesttest"
    , accountValidation = False
    , accountValidationMsg = EmptyMessage
    , accountRequestSuccess = False
    , keys = { privateKey = "", publicKey = "12o9347512f1oh923" }
    , keyCopied = False
    , email = "test@chain.partners"
    , emailValidationMsg = EmptyMessage
    , emailRequested = False
    , emailValid = False
    , confirmToken = ""
    , confirmTokenValid = False
    , emailConfirmationRequested = False
    , emailConfirmed = False
    , emailConfirmationMsg = EmptyMessage
    , agreeEosConstitution = False
    , notification = Notification.initModel
    }


tests : Test
tests =
    describe "EventCreation page module"
        [ describe "HTTP"
            [ test "createUserBodyParams" <|
                \() ->
                    let
                        expectedJson =
                            "{\"email\":\"" ++ model.email ++ "\"}"
                    in
                    Expect.equal (Http.stringBody "application/json" expectedJson) (createUserBodyParams model)
            , test "createEosAccountBodyParams" <|
                \() ->
                    let
                        expectedJson =
                            "{\"account_name\":\"" ++ model.accountName ++ "\",\"pubkey\":\"" ++ model.keys.publicKey ++ "\"}"
                    in
                    Expect.equal (Http.stringBody "application/json" expectedJson) (createEosAccountBodyParams model)
            ]
        ]
