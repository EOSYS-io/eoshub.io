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
    { accountValidation = AccountToBeVerified
    , quantityValidation = ValidQuantity
    , memoValidation = ValidMemo
    , isFormValid = False
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


getModelAfterValidation : Model -> Model
getModelAfterValidation model =
    Tuple.first (validate model balance NotSent)


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
                        ( { model
                            | transfer = { transfer | to = "newTo" }
                            , accountValidation = InvalidAccount
                            , quantityValidation = ValidQuantity
                          }
                        , Cmd.none
                        )
                        (setTransferMessageField To "newTo" model balance)
             , test "Quantity" <|
                \() ->
                    Expect.equal
                        { model
                            | transfer = { transfer | quantity = "0.1" }
                            , accountValidation = AccountToBeVerified
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
                            , accountValidation = AccountToBeVerified
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
             [ describe "account"
                [ test "EmptyAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "" }
                                , accountValidation = EmptyAccount
                              }
                            , Cmd.none
                            )
                            (validate
                                { model
                                    | transfer = { transfer | to = "" }
                                }
                                balance
                                NotSent
                            )
                , test "AccountToBeVerified" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | to = "eosio.ram" }
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | to = "eosio.ram" }
                                }
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
                            (validate { model | transfer = { transfer | to = "eosio.ram" } }
                                balance
                                Succeed
                            )
                , test "InexistentAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "eosio.ran" }
                                , isFormValid = False
                                , accountValidation = InexistentAccount
                              }
                            , Cmd.none
                            )
                            (validate { model | transfer = { transfer | to = "eosio.ran" } }
                                balance
                                Fail
                            )
                , test "InvalidAccount" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | transfer = { transfer | to = "abc1237" }
                                , accountValidation = InvalidAccount
                              }
                            , Cmd.none
                            )
                            (validate
                                { model
                                    | transfer = { transfer | to = "abc1237" }
                                }
                                balance
                                NotSent
                            )
                ]
             , describe "quantity"
                [ test "EmptyQuantity" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "" }
                                , quantityValidation = EmptyQuantity
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | quantity = "" }
                                }
                            )
                , test "InvalidQuantity" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "-1.0" }
                                , quantityValidation = InvalidQuantity
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | quantity = "-1.0" }
                                }
                            )
                , test "OverValidQuantity" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "301.0" }
                                , quantityValidation = OverValidQuantity
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | quantity = "301.0" }
                                }
                            )
                , test "ValidQuantity" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "299.9999" }
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | quantity = "299.9999" }
                                }
                            )
                ]
             , describe "memo"
                [ test "EmptyMemo" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | memo = "" }
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | memo = "" }
                                }
                            )
                , test "ValidMemo" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | memo = "hi~" }
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | memo = "hi~" }
                                }
                            )
                , test "InvalidMemo" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer =
                                    { transfer
                                        | memo = "This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes."
                                    }
                                , memoValidation = MemoTooLong
                            }
                            (getModelAfterValidation
                                { model
                                    | transfer = { transfer | memo = "This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes." }
                                }
                            )
                ]
             ]
            )
        ]
