module Test.Component.Main.Page.Transfer exposing (..)

import Expect
import Json.Encode as JE
import Component.Main.Page.Transfer exposing (..)
import Port
import Test exposing (..)


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
                                | transfer = { transfer | to = "newTo" }
                                , accountValidation = InvalidAccount
                                , quantityValidation = ValidQuantity
                                , isFormValid = False
                            }
                            (setTransferMessageField To "newTo" model balance)
                , test "Quantity is valid" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "0.1" }
                                , accountValidation = ValidAccount
                                , quantityValidation = ValidQuantity
                            }
                            (setTransferMessageField Quantity "0.1" model balance)
                , test "Quantity is invalid" <|
                    \() ->
                        Expect.equal
                            { model
                                | transfer = { transfer | quantity = "0.1" }
                                , accountValidation = ValidAccount
                                , quantityValidation = OverTransferableQuantity
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
                            (setTransferMessageField Memo "newMemo" model balance)
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
                                { model
                                    | transfer = { transfer | to = "" }
                                    , accountValidation = EmptyAccount
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | to = "" }
                                    }
                                    balance
                                )
                    , test "ValidAccount" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | to = "eosio.ram" }
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | to = "eosio.ram" }
                                    }
                                    balance
                                )
                    , test "InvalidAccount" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | to = "abc1237" }
                                    , accountValidation = InvalidAccount
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | to = "abc1237" }
                                    }
                                    balance
                                )
                    ]
                , describe "quantity"
                    [ test "EmptyQuantity" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | quantity = "" }
                                    , quantityValidation = EmptyQuantity
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | quantity = "" }
                                    }
                                    balance
                                )
                    , test "InvalidQuantity" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | quantity = "-1.0" }
                                    , quantityValidation = InvalidQuantity
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | quantity = "-1.0" }
                                    }
                                    balance
                                )
                    , test "OverTransferableQuantity" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | quantity = "301.0" }
                                    , quantityValidation = OverTransferableQuantity
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | quantity = "301.0" }
                                    }
                                    balance
                                )
                    , test "ValidQuantity" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | quantity = "299.9999" }
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | quantity = "299.9999" }
                                    }
                                    balance
                                )
                    ]
                , describe "memo"
                    [ test "EmptyMemo" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | memo = "" }
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | memo = "" }
                                    }
                                    balance
                                )
                    , test "ValidMemo" <|
                        \() ->
                            Expect.equal
                                { model
                                    | transfer = { transfer | memo = "hi~" }
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | memo = "hi~" }
                                    }
                                    balance
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
                                    , isFormValid = False
                                }
                                (validate
                                    { model
                                        | transfer = { transfer | memo = "This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes.This memo is over 256 bytes." }
                                    }
                                    balance
                                )
                    ]
                ]
            )
        ]
