module Test.Component.Main.Page.Transfer exposing (balance, model, submitActionTest, tests)

import Component.Main.Page.Transfer exposing (..)
import Expect
import Json.Encode as JE
import Port
import Test exposing (..)
import Util.Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        )


model : Model
model =
    { accountValidation = ValidAccount
    , quantityValidation = ValidQuantity
    , memoValidation = ValidMemo
    , isFormValid = True
    , transfer =
        { from = "from"
        , to = "to"
        , quantity = "300"
        , memo = "memo"
        }
    }


balance : Float
balance =
    300.0


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
                            | transfer = { transfer | to = "newto" }
                            , accountValidation = AccountToBeVerified
                            , isFormValid = False
                        }
                        (Tuple.first (setTransferMessageField To "newto" model balance))
             , test "Quantity" <|
                \() ->
                    Expect.equal
                        { model
                            | transfer = { transfer | quantity = "0.1" }
                            , quantityValidation = ValidQuantity
                        }
                        (Tuple.first
                            (setTransferMessageField Quantity "0.1" model balance)
                        )
             , test "Memo" <|
                \() ->
                    Expect.equal
                        { model
                            | transfer = { transfer | memo = "newMemo" }
                            , quantityValidation = ValidQuantity
                        }
                        (Tuple.first
                            (setTransferMessageField Memo "newMemo" model balance)
                        )
             ]
            )
        , describe "validation"
            (let
                { transfer } =
                    model
             in
             [ describe "validateToField"
                [ test "AccountToBeVerified" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | to = "eosio.ram" }
                                , accountValidation = AccountToBeVerified
                                , isFormValid = False
                            }
                            (Tuple.first
                                (validateToField
                                    { model
                                        | transfer = { transfer | to = "eosio.ram" }
                                    }
                                    NotSent
                                )
                            )
                , test "ValidAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "eosio.ram" }
                                , isFormValid = True
                                , accountValidation = ValidAccount
                              }
                            , Cmd.none
                            )
                            (validateToField
                                { model | transfer = { transfer | to = "eosio.ram" } }
                                Succeed
                            )
                , test "InexistentAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "eosio.ran" }
                                , accountValidation = InexistentAccount
                                , isFormValid = False
                              }
                            , Cmd.none
                            )
                            (validateToField
                                { model | transfer = { transfer | to = "eosio.ran" } }
                                Fail
                            )
                , test "InvalidAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "INVALID" }
                                , accountValidation = InvalidAccount
                                , isFormValid = False
                              }
                            , Cmd.none
                            )
                            (validateToField
                                { model | transfer = { transfer | to = "INVALID" } }
                                Fail
                            )
                , test "EmptyAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "" }
                                , accountValidation = EmptyAccount
                                , isFormValid = False
                              }
                            , Cmd.none
                            )
                            (validateToField
                                { model | transfer = { transfer | to = "" } }
                                Fail
                            )
                ]
             ]
            )
        ]
