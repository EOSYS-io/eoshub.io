module Test.Component.Account.Page.EventCreation exposing (model, tests)

import Component.Account.Page.EventCreation exposing (..)
import Expect
import Http
import Test exposing (..)
import Translation exposing (I18n(EmptyMessage))
import Util.Validation exposing (AccountStatus(..))
import View.Notification as Notification


model : Model
model =
    { accountName = "testtesttest"
    , accountValidation = EmptyAccount
    , accountRequestSuccess = False
    , keys = { privateKey = "", publicKey = "12o9347512f1oh923" }
    , email = "test@chain.partners"
    , emailValid = False
    , confirmToken = ""
    , confirmTokenValid = False
    , emailConfirmationRequested = False
    , emailConfirmed = False
    , agreeEosConstitution = False
    , notification = Notification.initModel
    , emailValidationSecondsLeft = 0
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
                    Expect.equal (Http.stringBody "application/json" expectedJson) (sendCodeBodyParams model)
            , test "createEosAccountBodyParams" <|
                \() ->
                    let
                        expectedJson =
                            "{\"account_name\":\"" ++ model.accountName ++ "\",\"pubkey\":\"" ++ model.keys.publicKey ++ "\"}"
                    in
                    Expect.equal (Http.stringBody "application/json" expectedJson) (createEosAccountBodyParams model)
            ]
        ]
