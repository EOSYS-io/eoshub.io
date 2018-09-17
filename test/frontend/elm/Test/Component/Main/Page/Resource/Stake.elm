module Test.Component.Main.Page.Resource.Stake exposing (tests)

import Component.Main.Page.Resource.Stake exposing (..)
import Expect
import Test exposing (..)
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , validateAccount
        , validateMemo
        , validateQuantity
        )



-- TODO(boseok): tests for Stake.update


tests : Test
tests =
    describe "Page.Resource.Stake module"
        [ describe "initModel"
            [ test "delegatebw.transfer should always be 0 when from == receiver" <|
                \() ->
                    Expect.equal 0 initModel.delegatebw.transfer
            ]
        , describe "getPercentageOfLiquid"
            [ test "Percentage10" <|
                \() ->
                    Expect.equal 0.1 (getPercentageOfLiquid Percentage10)
            , test "Percentage50" <|
                \() ->
                    Expect.equal 0.5 (getPercentageOfLiquid Percentage50)
            , test "Percentage70" <|
                \() ->
                    Expect.equal 0.7 (getPercentageOfLiquid Percentage70)
            , test "Percentage100" <|
                \() ->
                    Expect.equal 1 (getPercentageOfLiquid Percentage100)
            , test "NoOp" <|
                \() ->
                    Expect.equal 0 (getPercentageOfLiquid NoOp)
            ]
        , describe "validate"
            -- TODO(boseok): these tests only cover totalQuantity validation and modal open/close validation cases
            -- rest cases are TODO
            [ test "validate test1. modal closed, total = ValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            initModel

                        { delegatebw } =
                            defaultModel

                        newModel =
                            { defaultModel
                                | delegatebw =
                                    { delegatebw
                                        | stakeNetQuantity = "0.0600 EOS"
                                        , stakeCpuQuantity = "0.2400 EOS"
                                        , transfer = 1
                                    }
                                , totalQuantity = "0.3"
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            False

                        expectedModel =
                            { newModel
                                | totalQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , netQuantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            , test "validate test2. modal closed, total = OverValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            initModel

                        { delegatebw } =
                            defaultModel

                        newModel =
                            { defaultModel
                                | delegatebw =
                                    { delegatebw
                                        | stakeNetQuantity = "0.0800 EOS"
                                        , stakeCpuQuantity = "0.3200 EOS"
                                        , transfer = 1
                                    }
                                , totalQuantity = "0.4"
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            False

                        expectedModel =
                            { newModel
                                | totalQuantityValidation = OverValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , netQuantityValidation = ValidQuantity
                                , isFormValid = False
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            , test "validate test3. modal opened, cpu + net -> OverValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            initModel

                        { stakeAmountModal } =
                            defaultModel

                        newModel =
                            { defaultModel
                                | stakeAmountModal =
                                    { stakeAmountModal
                                        | totalQuantity = "0.4"
                                        , cpuQuantity = "0.2"
                                        , netQuantity = "0.2"
                                    }
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            True

                        newStakeAmountModal =
                            newModel.stakeAmountModal

                        expectedModel =
                            { newModel
                                | stakeAmountModal =
                                    { newStakeAmountModal
                                        | totalQuantityValidation = OverValidQuantity
                                        , cpuQuantityValidation = ValidQuantity
                                        , netQuantityValidation = ValidQuantity
                                        , isFormValid = False
                                    }
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            , test "validate test4. modal opened, cpu + net -> ValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            initModel

                        { stakeAmountModal } =
                            defaultModel

                        newModel =
                            { defaultModel
                                | stakeAmountModal =
                                    { stakeAmountModal
                                        | totalQuantity = "0.3"
                                        , cpuQuantity = "0.2"
                                        , netQuantity = "0.1"
                                    }
                                , isStakeAmountModalOpened = True
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            newModel.isStakeAmountModalOpened

                        newStakeAmountModal =
                            newModel.stakeAmountModal

                        expectedModel =
                            { newModel
                                | stakeAmountModal =
                                    { newStakeAmountModal
                                        | totalQuantityValidation = ValidQuantity
                                        , cpuQuantityValidation = ValidQuantity
                                        , netQuantityValidation = ValidQuantity
                                        , isFormValid = True
                                    }
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            ]
        , describe "distributeCpuNet"
            [ test "distributeCpuNet \"1.0000 EOS\" 1 2 " <|
                \() ->
                    let
                        expected =
                            ( "0.3333 EOS", "0.6667 EOS" )
                    in
                    Expect.equal expected (distributeCpuNet "1.0000 EOS" 1 2)
            ]
        , describe "modalValidateAttr"
            [ test "resourceQuantityStatus -> EmptyQuantity" <|
                \() ->
                    Expect.equal "" (modalValidateAttr InvalidQuantity EmptyQuantity)
            , test "resourceQuantityStatus -> ValidQuantity, but totalQuantityStatus -> not ValidQuantity" <|
                \() ->
                    Expect.equal "false" (modalValidateAttr InvalidQuantity ValidQuantity)
            , test "resourceQuantityStatus -> ValidQuantity && totalQuantityStatus -> ValidQuantity" <|
                \() ->
                    Expect.equal "true" (modalValidateAttr ValidQuantity ValidQuantity)
            , test "resourceQuantityStatus -> else cases " <|
                \() ->
                    Expect.equal "false" (modalValidateAttr InvalidQuantity InvalidQuantity)
            ]
        ]
