module Test.Component.Main.Page.Resource.Delegate exposing (tests)

import Component.Main.Page.Resource.Delegate exposing (..)
import Expect
import Test exposing (..)
import Translation exposing (I18n(..), Language(..), translate)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , VerificationRequestStatus(..)
        , validateAccount
        , validateMemo
        , validateQuantity
        )



-- TODO(boseok): tests for Delegate.update


tests : Test
tests =
    let
        defaultModel =
            initModel

        accountValid =
            "eosyscommuni"

        { delegatebw } =
            defaultModel

        eosLiquidAmount =
            0.7
    in
    describe "Page.Resource.Delegate module"
        [ describe "Validate the account field."
            [ test "validate test1. accountValidation InvalidAccount" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | delegatebw =
                                    { delegatebw
                                        | receiver = "!@#$%^&!@#!!"
                                    }
                            }

                        expectedModel =
                            { newModel
                                | accountValidation = InvalidAccount
                                , isFormValid = False
                            }
                    in
                    Expect.equal expectedModel (Tuple.first (validateReceiverField newModel NotSent))

            -- TODO(heejae, boseok): Validate quantity fields with valid account.
            , describe "Validate quantity fields."
                [ test "validate test2. cpu EmptyQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.9000"
                                            , stakeCpuQuantity = ""
                                        }
                                    , totalQuantity = "0.9000"
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = OverValidQuantity
                                    , totalQuantityValidation = OverValidQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validateQuantityFields newModel eosLiquidAmount)
                , test "validate test3. cpu OverValidQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = ""
                                            , stakeCpuQuantity = "0.9000"
                                        }
                                    , totalQuantity = "0.9000"
                                }

                            expectedModel =
                                { newModel
                                    | cpuQuantityValidation = OverValidQuantity
                                    , totalQuantityValidation = OverValidQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validateQuantityFields newModel eosLiquidAmount)
                , test "validate test4. cpu ValidQuantity, net ValidQuantity, total OverValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.5000"
                                            , stakeCpuQuantity = "0.5000"
                                        }
                                    , totalQuantity = "1.0000"
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = OverValidQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validateQuantityFields newModel eosLiquidAmount)
                , test "validate test5. cpu ValidQuantity, net ValidQuantity, total ValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.3000"
                                            , stakeCpuQuantity = "0.3000"
                                        }
                                    , totalQuantity = "0.6000"
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = ValidQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validateQuantityFields newModel eosLiquidAmount)
                , test "validate test6. cpu EmptyQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            expectedModel =
                                { defaultModel
                                    | netQuantityValidation = EmptyQuantity
                                    , cpuQuantityValidation = EmptyQuantity
                                    , totalQuantityValidation = EmptyQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validateQuantityFields defaultModel eosLiquidAmount)
                ]
            ]

        -- TODO(boseok):validateEach test
        , describe "validateText"
            [ describe "accountValidation Valid"
                [ test "both EmptyQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                initModel

                            expected =
                                ( translate Korean NeverExceedDelegateAmount, "" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                , test "cpu ValidQuantity, net ValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = ValidQuantity
                                    , accountValidation = AccountToBeVerified
                                }

                            expected =
                                ( translate Korean TypeAccountToDelegate, " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                ]
            , describe "accountValidation Invalid or Empty"
                [ test "cpu OverValidQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | cpuQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( translate Korean (InvalidQuantityInput "CPU"), " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                , test "cpu EmptyQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( translate Korean (InvalidQuantityInput "NET"), " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                , test "cpu OverValidQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = OverValidQuantity
                                    , cpuQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( translate Korean (InvalidQuantityInput "CPU, NET"), " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                , test "cpu ValidQuantity, net ValidQuantity, total OverValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( translate Korean ExceedDelegateAmount, " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                , test "cpu ValidQuantity, net ValidQuantity, total ValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = ValidQuantity
                                }

                            expected =
                                ( translate Korean TypeAccountToDelegate, " false" )
                        in
                        Expect.equal expected (validateText Korean defaultModel)
                ]
            ]
        ]
