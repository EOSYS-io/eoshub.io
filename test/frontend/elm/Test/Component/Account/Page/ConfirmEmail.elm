module Test.Component.Account.Page.ConfirmEmail exposing (..)

import Expect
import Http
import Component.Account.Page.ConfirmEmail exposing (..)
import Test exposing (..)
import View.Notification as Notification


model : Model
model =
    { email = "test@chain.partners"
    , validationMsg = "Please enter an email address."
    , requested = False
    , emailValid = False
    , inputValid = "invalid"
    , notification = Notification.initModel
    }


tests : Test
tests =
    describe "ConfirmEmail page module"
        [ describe "HTTP"
            [ let
                expectedJson =
                    "{\"email\":\"" ++ model.email ++ "\"}"
              in
                test "createUserBodyParams" <|
                    \() -> Expect.equal (Http.stringBody "application/json" expectedJson) (createUserBodyParams model)
            ]
        ]
