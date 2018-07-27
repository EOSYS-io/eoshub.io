module Test.Component.Account.Page.Create exposing (..)

import Expect
import Http
import Component.Account.Page.Create exposing (..)
import Test exposing (..)
import View.Notification as Notification


model : Model
model =
    { accountName = "testtesttest"
    , pubkey = "12o9347512f1oh923"
    , validation = False
    , validationMsg = ""
    , requestSuccess = False
    , notification = Notification.initModel
    }


tests : Test
tests =
    describe "Create page module"
        [ describe "HTTP"
            [ let
                expectedJson =
                    "{\"account_name\":\"" ++ model.accountName ++ "\",\"pubkey\":\"" ++ model.pubkey ++ "\"}"
              in
                test "createEosAccountBodyParams" <|
                    \() -> Expect.equal (Http.stringBody "application/json" expectedJson) (createEosAccountBodyParams model)
            ]
        ]
