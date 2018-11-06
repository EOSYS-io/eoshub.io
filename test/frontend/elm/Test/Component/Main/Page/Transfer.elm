module Test.Component.Main.Page.Transfer exposing
    ( balance
    , model
    , tests
    )

import Component.Main.Page.Transfer exposing (..)
import Data.Table
import Dict
import Expect
import Http
import Json.Encode as JE
import Port
import Test exposing (..)
import Util.Token exposing (Token)
import Util.Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        )


addToken : Token
addToken =
    { name = "ADD"
    , symbol = "ADD"
    , contractAccount = "testacc"
    , precision = 4
    }


blackToken : Token
blackToken =
    { name = "eosBLACK"
    , symbol = "BLACK"
    , contractAccount = "eosblackteam"
    , precision = 4
    }


model : Model
model =
    { accountValidation = ValidAccount
    , quantityValidation = ValidQuantity
    , memoValidation = ValidMemo
    , isFormValid = True
    , transfer =
        { from = "from"
        , to = "to"
        , quantity = "3.0"
        , memo = "memo"
        }
    , possessingTokens =
        Dict.fromList
            [ ( "ADD", ( addToken, "3.0123 ADD" ) )
            ]
    , token = addToken
    , modalOpened = True
    , tokensLoaded = False
    , tokenBalance = "3.0123 ADD"
    , tokenSearchInput = ""
    }


balance : Float
balance =
    300.0


tests : Test
tests =
    let
        submitActionTest =
            let
                expectedJson =
                    JE.object
                        [ ( "account", JE.string "testacc" )
                        , ( "action", JE.string "transfer" )
                        , ( "payload"
                          , JE.object
                                [ ( "from", JE.string "from" )
                                , ( "to", JE.string "to" )
                                , ( "quantity", JE.string "3.0000 ADD" )
                                , ( "memo", JE.string "memo" )
                                ]
                          )
                        ]
            in
            test "SubmitAction" <|
                \() -> Expect.equal ( model, Port.pushAction expectedJson ) (update SubmitAction model "from" 300.0)

        switchTokenTest =
            let
                newToken =
                    { name = "BLACK"
                    , symbol = "BLACK"
                    , contractAccount = "testblack"
                    , precision = 4
                    }
            in
            test "SwitchToken" <|
                \() ->
                    Expect.equal
                        { model
                            | modalOpened = False
                            , transfer = { from = "", to = "", quantity = "", memo = "" }
                            , accountValidation = EmptyAccount
                            , quantityValidation = EmptyQuantity
                            , memoValidation = EmptyMemo
                            , tokenBalance = "40.0000 BLACK"
                            , token = newToken
                        }
                        (Tuple.first
                            (update
                                (SwitchToken ( newToken, "40.0000 BLACK" ))
                                model
                                "from"
                                300.0
                            )
                        )

        onFetchTableRowsTest =
            let
                blackBalance =
                    Data.Table.Accounts { balance = "40.0000 BLACK" }

                bchBalance =
                    Data.Table.Accounts { balance = "1.0000 BCH" }
            in
            describe "OnFetchTableRows"
                [ test "Ok with empty rows" <|
                    \() ->
                        Expect.equal ( model, Cmd.none )
                            (update (OnFetchTableRows (Ok [])) model "from" 300.0)
                , test "Ok with matched symbol" <|
                    \() ->
                        Expect.equal
                            ( { model
                                | possessingTokens =
                                    Dict.insert "BLACK" ( blackToken, "40.0000 BLACK" ) model.possessingTokens
                              }
                            , Cmd.none
                            )
                            (update (OnFetchTableRows (Ok [ blackBalance ])) model "from" 300.0)
                , test "Ok with no matched symbol" <|
                    \() ->
                        Expect.equal ( model, Cmd.none )
                            (update (OnFetchTableRows (Ok [ bchBalance ])) model "from" 300.0)
                , test "Err" <|
                    \() ->
                        Expect.equal ( model, Cmd.none )
                            (update (OnFetchTableRows (Err Http.Timeout)) model "from" 300.0)
                ]
    in
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
