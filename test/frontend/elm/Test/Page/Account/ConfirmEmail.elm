module Test.Page.Account.ConfirmEmail exposing (..)

import Expect
import Http
import Page.Account.ConfirmEmail exposing (..)
import Test exposing (..)


model : Model
model =
    { email = "test@chain.partners"
    , requestStatus = { msg = "" }
    , flags = { node_env = "test" }
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
