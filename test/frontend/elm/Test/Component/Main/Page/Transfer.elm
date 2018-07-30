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
            \() -> Expect.equal ( model, Port.pushAction expectedJson ) (update SubmitAction model "from" 300.0)


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
                            (setTransferMessageField To "newTo" model 300.0)
                , test "Quantity is valid" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "0.1" }
                                , accountValidation = ValidAccount
                                , quantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                            (setTransferMessageField Quantity "0.1" model 300.0)
                , test "Quantity is invalid" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "0.1" }
                                , accountValidation = ValidAccount
                                , quantityValidation = InvalidQuantity
                                , isFormValid = False
                            }
                            (setTransferMessageField Quantity "0.1" model 0.0)
                , test "Memo" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | memo = "newMemo" }
                                , accountValidation = ValidAccount
                                , quantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                            (setTransferMessageField Memo "newMemo" model 300.0)
                ]
            )
        ]
