module Test.Page.Account.Create exposing (..)

import Expect
import Http
import Page.Account.Create exposing (..)
import Test exposing (..)


model : Model
model =
    { accountName = "testtesttest"
    , requestStatus = { msg = "" }
    , pubkey = "12o9347512f1oh923"
    , validation = False
    , validationMsg = ""
    , requestSuccess = False
    , confirmToken = "test" }


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
