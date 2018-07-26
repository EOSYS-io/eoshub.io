module Test.Component.Main.Page.Transfer exposing (..)

import Expect
import Json.Encode as JE
import Component.Main.Page.Transfer exposing (..)
import Port
import Test exposing (..)


model : Model
model =
    { accountValidation = EmptyAccount
    , quantityValidation = EmptyQuantity
    , memoValidation = ValidMemo
    , isFormValid = False
    , transfer =
        { from = "from"
        , to = "to"
        , quantity = "300"
        , memo = "memo"
        }
    }


submitActionTest : Test
submitActionTest =
    let
        expectedJson =
            JE.object
                [ ( "account", JE.string "eosio.token" )
                , ( "action", JE.string "transfer" )
                , ( "payload"
                  , JE.object
                        [ ( "from", JE.string "from" )
                        , ( "to", JE.string "to" )
                        , ( "quantity", JE.string "300.0000 EOS" )
                        , ( "memo", JE.string "memo" )
                        ]
                  )
                ]
    in
        test "SubmitAction" <|
            \() -> Expect.equal ( model, Port.pushAction expectedJson ) (update SubmitAction model "from")


tests : Test
tests =
    describe "Transfer page module"
        [ describe "update"
            [ submitActionTest ]
        , describe "setTransferMessageField"
            (let
                { transfer } =
                    model
             in
                [ test "To" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | to = "newTo" }
                                , accountValidation = InvalidAccount
                                , quantityValidation = ValidQuantity
                            }
                            (setTransferMessageField To "newTo" model)
                , test "Quantity" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "301" }
                                , accountValidation = ValidAccount
                                , quantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                            (setTransferMessageField Quantity "301" model)
                , test "Memo" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | memo = "newMemo" }
                                , accountValidation = ValidAccount
                                , quantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                            (setTransferMessageField Memo "newMemo" model)
                ]
            )
        ]