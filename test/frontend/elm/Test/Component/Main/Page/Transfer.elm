module Test.Component.Main.Page.Transfer exposing
    ( balance
    , model
    , onFetchTableRowsTest
    , submitActionTest
    , switchTokenTest
    , tests
    )

import Component.Main.Page.Transfer exposing (..)
import Data.Table
import Expect
import Http
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
    , token =
        { name = "SYS"
        , symbol = "SYS"
        , contractAccount = "eosio.token"
        , precision = 4
        }
    , modalOpened = True
    , tokenBalance = "3.0123 SYS"
    , tokenSearchInput = ""
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
                        , ( "quantity", JE.string "300.0000 SYS" )
                        , ( "memo", JE.string "memo" )
                        ]
                  )
                ]
    in
    test "SubmitAction" <|
        \() -> Expect.equal ( model, Port.pushAction expectedJson ) (update SubmitAction model "from" 300.0)


switchTokenTest : Test
switchTokenTest =
    test "SwitchToken" <|
        \() ->
            Expect.equal
                { model
                    | modalOpened = False
                    , transfer = { from = "", to = "", quantity = "", memo = "" }
                    , accountValidation = EmptyAccount
                    , quantityValidation = EmptyQuantity
                    , memoValidation = EmptyMemo
                }
                (Tuple.first
                    (update
                        (SwitchToken
                            { name = "SYS"
                            , symbol = "SYS"
                            , contractAccount = "eosio.token"
                            , precision = 4
                            }
                        )
                        model
                        "from"
                        300.0
                    )
                )


onFetchTableRowsTest : Test
onFetchTableRowsTest =
    let
        defaultSysAmount =
            "0.0000 SYS"

        sysBalance =
            Data.Table.Accounts { balance = "4.0000 SYS" }

        btcBalance =
            Data.Table.Accounts { balance = "1.00000000 BTC" }
    in
    describe "OnFetchTableRows"
        [ test "Ok with empty rows" <|
            \() ->
                Expect.equal ( { model | tokenBalance = defaultSysAmount }, Cmd.none )
                    (update (OnFetchTableRows (Ok [])) model "from" 300.0)
        , test "Ok with matched symbol at head" <|
            \() ->
                Expect.equal ( { model | tokenBalance = "4.0000 SYS" }, Cmd.none )
                    (update (OnFetchTableRows (Ok [ sysBalance, btcBalance ])) model "from" 300.0)
        , test "Ok with matched symbol at tail" <|
            \() ->
                Expect.equal ( { model | tokenBalance = "4.0000 SYS" }, Cmd.none )
                    (update (OnFetchTableRows (Ok [ btcBalance, sysBalance ])) model "from" 300.0)
        , test "Ok with no matched symbols" <|
            \() ->
                Expect.equal ( { model | tokenBalance = "0.0000 SYS" }, Cmd.none )
                    (update (OnFetchTableRows (Ok [ btcBalance, btcBalance ])) model "from" 300.0)
        , test "Err" <|
            \() ->
                Expect.equal ( { model | tokenBalance = "0.0000 SYS" }, Cmd.none )
                    (update (OnFetchTableRows (Err Http.Timeout)) model "from" 300.0)
        ]


tests : Test
tests =
    describe "Transfer page module"
        [ describe "update"
            [ submitActionTest
            , switchTokenTest
            , onFetchTableRowsTest
            ]
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
