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


getModelAfterValidation : Model -> Model
getModelAfterValidation model =
    let
        eosLiquidAmount =
            0.7
    in
    Tuple.first (validate model eosLiquidAmount NotSent)



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
    in
    describe "Page.Resource.Delegate module"
        [ describe "validate"
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
                    Expect.equal expectedModel (getModelAfterValidation newModel)
            , describe "accountValidation AccountToBeVerified"
                [ test "validate test2. cpu EmptyQuantity, net OverValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.9000"
                                            , stakeCpuQuantity = ""
                                            , receiver = accountValid
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = OverValidQuantity
                                    , accountValidation = AccountToBeVerified
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (getModelAfterValidation newModel)
                , test "validate test3. cpu OverValidQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = ""
                                            , stakeCpuQuantity = "0.9000"
                                            , receiver = accountValid
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | cpuQuantityValidation = OverValidQuantity
                                    , accountValidation = AccountToBeVerified
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (getModelAfterValidation newModel)
                , test "validate test4. cpu ValidQuantity, net ValidQuantity, total OverValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.5000"
                                            , stakeCpuQuantity = "0.5000"
                                            , receiver = accountValid
                                        }
                                    , totalQuantity = "1.0000"
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = OverValidQuantity
                                    , accountValidation = AccountToBeVerified
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (getModelAfterValidation newModel)
                , test "validate test5. cpu ValidQuantity, net ValidQuantity, total ValidQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | stakeNetQuantity = "0.3000"
                                            , stakeCpuQuantity = "0.3000"
                                            , receiver = accountValid
                                        }
                                    , totalQuantity = "0.6000"
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = ValidQuantity
                                    , totalQuantityValidation = ValidQuantity
                                    , accountValidation = AccountToBeVerified
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (getModelAfterValidation newModel)
                , test "validate test6. cpu EmptyQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | delegatebw =
                                        { delegatebw
                                            | receiver = accountValid
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | netQuantityValidation = EmptyQuantity
                                    , cpuQuantityValidation = EmptyQuantity
                                    , accountValidation = AccountToBeVerified
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (getModelAfterValidation newModel)
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
