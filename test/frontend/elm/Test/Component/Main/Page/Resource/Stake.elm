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
    describe "Page.SearchKey module"
        [ describe "getPercentageOfLiquid"
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
            [ test "validate test1. modal closed, total = ValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { delegatebw =
                                { from = "", receiver = "", stakeNetQuantity = "0.0600 EOS", stakeCpuQuantity = "0.2400 EOS", transfer = 1 }
                            , totalQuantity = "0.3"
                            , percentageOfLiquid = NoOp
                            , distributionRatio =
                                { cpu = 4, net = 1 }
                            , totalQuantityValidation = InvalidQuantity
                            , cpuQuantityValidation = InvalidQuantity
                            , netQuantityValidation = InvalidQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = False
                            , stakeAmountModal =
                                { totalQuantity = "0"
                                , cpuQuantity = ""
                                , netQuantity = ""
                                , totalQuantityValidation = EmptyQuantity
                                , cpuQuantityValidation = EmptyQuantity
                                , netQuantityValidation = EmptyQuantity
                                , isFormValid = False
                                }
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            False

                        expectedModel =
                            { delegatebw =
                                { from = ""
                                , receiver = ""
                                , stakeNetQuantity = "0.0600 EOS"
                                , stakeCpuQuantity = "0.2400 EOS"
                                , transfer = 1
                                }
                            , totalQuantity = "0.3"
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = ValidQuantity
                            , cpuQuantityValidation = ValidQuantity
                            , netQuantityValidation = ValidQuantity
                            , manuallySet = False
                            , isFormValid = True
                            , isStakeAmountModalOpened = False
                            , stakeAmountModal = { totalQuantity = "0", cpuQuantity = "", netQuantity = "", totalQuantityValidation = EmptyQuantity, cpuQuantityValidation = EmptyQuantity, netQuantityValidation = EmptyQuantity, isFormValid = False }
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            , test "validate test2. modal closed, total = OverValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { delegatebw = { from = "", receiver = "", stakeNetQuantity = "0.0800 EOS", stakeCpuQuantity = "0.3200 EOS", transfer = 1 }
                            , totalQuantity = "0.4"
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = InvalidQuantity
                            , cpuQuantityValidation = InvalidQuantity
                            , netQuantityValidation = InvalidQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = False
                            , stakeAmountModal =
                                { totalQuantity = "0"
                                , cpuQuantity = ""
                                , netQuantity = ""
                                , totalQuantityValidation = EmptyQuantity
                                , cpuQuantityValidation = EmptyQuantity
                                , netQuantityValidation = EmptyQuantity
                                , isFormValid =
                                    False
                                }
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            False

                        expectedModel =
                            { delegatebw = { from = "", receiver = "", stakeNetQuantity = "0.0800 EOS", stakeCpuQuantity = "0.3200 EOS", transfer = 1 }
                            , totalQuantity = "0.4"
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = OverValidQuantity
                            , cpuQuantityValidation = ValidQuantity
                            , netQuantityValidation = ValidQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = False
                            , stakeAmountModal =
                                { totalQuantity = "0"
                                , cpuQuantity = ""
                                , netQuantity = ""
                                , totalQuantityValidation = EmptyQuantity
                                , cpuQuantityValidation = EmptyQuantity
                                , netQuantityValidation = EmptyQuantity
                                , isFormValid = False
                                }
                            }
                    in
                    Expect.equal expectedModel (validate newModel liquidAmount modalOpened)
            , test "validate test3. modal opened, cpu + net -> OverValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 1 }
                            , totalQuantity = ""
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = EmptyQuantity
                            , cpuQuantityValidation = EmptyQuantity
                            , netQuantityValidation = EmptyQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = True
                            , stakeAmountModal =
                                { totalQuantity = "0.4"
                                , cpuQuantity = "0.2"
                                , netQuantity = "0.2"
                                , totalQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , netQuantityValidation = InvalidQuantity
                                , isFormValid = False
                                }
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            True

                        expectedModel =
                            { delegatebw = { from = "", receiver = "", stakeNetQuantity = "", stakeCpuQuantity = "", transfer = 1 }
                            , totalQuantity = ""
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = EmptyQuantity
                            , cpuQuantityValidation = EmptyQuantity
                            , netQuantityValidation = EmptyQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = True
                            , stakeAmountModal =
                                { totalQuantity = "0.4"
                                , cpuQuantity = "0.2"
                                , netQuantity = "0.2"
                                , totalQuantityValidation = OverValidQuantity
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
                        newModel =
                            { delegatebw =
                                { from = ""
                                , receiver = ""
                                , stakeNetQuantity = ""
                                , stakeCpuQuantity = ""
                                , transfer = 1
                                }
                            , totalQuantity = ""
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = EmptyQuantity
                            , cpuQuantityValidation = EmptyQuantity
                            , netQuantityValidation = EmptyQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = True
                            , stakeAmountModal =
                                { totalQuantity = "0.3"
                                , cpuQuantity = "0.2"
                                , netQuantity = "0.1"
                                , totalQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , netQuantityValidation = InvalidQuantity
                                , isFormValid = False
                                }
                            }

                        liquidAmount =
                            0.3532

                        modalOpened =
                            True

                        expectedModel =
                            { delegatebw =
                                { from = ""
                                , receiver = ""
                                , stakeNetQuantity = ""
                                , stakeCpuQuantity = ""
                                , transfer = 1
                                }
                            , totalQuantity = ""
                            , percentageOfLiquid = NoOp
                            , distributionRatio = { cpu = 4, net = 1 }
                            , totalQuantityValidation = EmptyQuantity
                            , cpuQuantityValidation = EmptyQuantity
                            , netQuantityValidation = EmptyQuantity
                            , manuallySet = False
                            , isFormValid = False
                            , isStakeAmountModalOpened = True
                            , stakeAmountModal =
                                { totalQuantity = "0.3"
                                , cpuQuantity = "0.2"
                                , netQuantity = "0.1"
                                , totalQuantityValidation = ValidQuantity
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
