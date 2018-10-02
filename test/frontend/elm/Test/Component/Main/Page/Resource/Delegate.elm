module Test.Component.Main.Page.Resource.Delegate exposing (tests)

import Component.Main.Page.Resource.Delegate exposing (..)
import Expect
import Test exposing (..)
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
        -- TODO(boseok):translation
        , describe "validateText"
            [ describe "accountValidation Valid"
                [ test "both EmptyQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                initModel

                            expected =
                                ( "임대가능한 토큰 수만큼 임대가 가능합니다", "" )
                        in
                        Expect.equal expected (validateText defaultModel)
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
                                ( "임대해줄 계정을 입력하세요", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
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
                                ( "CPU의 수량입력이 잘못되었습니다", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
                , test "cpu EmptyQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( "NET의 수량입력이 잘못되었습니다", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
                , test "cpu OverValidQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            defaultModel =
                                { initModel
                                    | netQuantityValidation = OverValidQuantity
                                    , cpuQuantityValidation = OverValidQuantity
                                }

                            expected =
                                ( "CPU, NET의 수량입력이 잘못되었습니다", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
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
                                ( "임대가능 토큰수량을 초과하였습니다", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
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
                                ( "임대해줄 계정을 입력하세요", " false" )
                        in
                        Expect.equal expected (validateText defaultModel)
                ]
            ]
        ]
