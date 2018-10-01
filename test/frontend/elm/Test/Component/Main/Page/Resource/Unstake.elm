module Test.Component.Main.Page.Resource.Unstake exposing (tests)

import Component.Main.Page.Resource.Unstake exposing (..)
import Expect
import Test exposing (..)
import Translation
    exposing
        ( I18n(..)
        , Language(Chinese, English, Korean)
        , getMessages
        , toLanguage
        , toLocale
        , translate
        )
import Util.Validation as Validation
    exposing
        ( AccountStatus(..)
        , MemoStatus(..)
        , QuantityStatus(..)
        , validateAccount
        , validateMemo
        , validateQuantity
        )



-- TODO(boseok): tests for Unstake.update


tests : Test
tests =
    let
        unstakePossibleCpu =
            "0.3 EOS"

        unstakePossibleNet =
            "0.4 EOS"

        defaultModel =
            initModel

        { undelegatebw } =
            defaultModel
    in
    describe "Page.Resource.Unstake module"
        [ describe "getPercentageOfResource"
            [ test "Percentage10" <|
                \() ->
                    Expect.equal 0.1 (getPercentageOfResource Percentage10)
            , test "Percentage50" <|
                \() ->
                    Expect.equal 0.5 (getPercentageOfResource Percentage50)
            , test "Percentage70" <|
                \() ->
                    Expect.equal 0.7 (getPercentageOfResource Percentage70)
            , test "Percentage100" <|
                \() ->
                    Expect.equal 1 (getPercentageOfResource Percentage100)
            , test "NoOp" <|
                \() ->
                    Expect.equal 1 (getPercentageOfResource NoOp)
            ]
        , describe "getUnstakePossibleResource"
            [ test "cpu, selfDelegatedAmount > minimum (0.8 EOS)" <|
                \() ->
                    let
                        minimum =
                            initModel.minimumResource.cpu

                        selfDelegatedAcount =
                            "1.3000 EOS"

                        expected =
                            "0.5000 EOS"
                    in
                    Expect.equal expected (getUnstakePossibleResource selfDelegatedAcount minimum)
            , test "cpu, selfDelegatedAmount <= minimum (0.8 EOS)" <|
                \() ->
                    let
                        minimum =
                            initModel.minimumResource.cpu

                        selfDelegatedAcount =
                            "0.3000 EOS"

                        expected =
                            "0 EOS"
                    in
                    Expect.equal expected (getUnstakePossibleResource selfDelegatedAcount minimum)
            , test "net, selfDelegatedAmount > minimum (0.2 EOS)" <|
                \() ->
                    let
                        minimum =
                            initModel.minimumResource.net

                        selfDelegatedAcount =
                            "0.3000 EOS"

                        expected =
                            "0.1000 EOS"
                    in
                    Expect.equal expected (getUnstakePossibleResource selfDelegatedAcount minimum)
            , test "net, selfDelegatedAmount <= minimum (0.2 EOS)" <|
                \() ->
                    let
                        minimum =
                            initModel.minimumResource.net

                        selfDelegatedAcount =
                            "0.1000 EOS"

                        expected =
                            "0 EOS"
                    in
                    Expect.equal expected (getUnstakePossibleResource selfDelegatedAcount minimum)
            ]
        , describe "validate"
            [ test "validate test1. cpu ValidQuantity, net EmptyQuantity" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | undelegatebw =
                                    { undelegatebw
                                        | unstakeCpuQuantity = "0.0600"
                                    }
                            }

                        expectedModel =
                            { newModel
                                | cpuQuantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                    in
                    Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
            , test "validate test2. cpu EmptyQuantity, net ValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | undelegatebw =
                                    { undelegatebw
                                        | unstakeNetQuantity = "0.0600"
                                        , unstakeCpuQuantity = ""
                                    }
                            }

                        expectedModel =
                            { newModel
                                | netQuantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                    in
                    Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
            , test "validate test3. cpu ValidQuantity, net ValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | undelegatebw =
                                    { undelegatebw
                                        | unstakeNetQuantity = "0.0600"
                                        , unstakeCpuQuantity = "0.1000"
                                    }
                            }

                        expectedModel =
                            { newModel
                                | netQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , isFormValid = True
                            }
                    in
                    Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
            , test "validate test4. cpu OverValidQuantity, net ValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | undelegatebw =
                                    { undelegatebw
                                        | unstakeNetQuantity = "1.0000"
                                        , unstakeCpuQuantity = "0.1000"
                                    }
                            }

                        expectedModel =
                            { newModel
                                | netQuantityValidation = OverValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                                , isFormValid = False
                            }
                    in
                    Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
            , test "validate test5. cpu ValidQuantity, net OverValidQuantity" <|
                \() ->
                    let
                        newModel =
                            { defaultModel
                                | undelegatebw =
                                    { undelegatebw
                                        | unstakeNetQuantity = "0.1000"
                                        , unstakeCpuQuantity = "1.1000"
                                    }
                            }

                        expectedModel =
                            { newModel
                                | netQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = OverValidQuantity
                                , isFormValid = False
                            }
                    in
                    Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
            , test "validate test6. cpu EmptyQuantity, net EmptyQuantity" <|
                \() ->
                    let
                        expectedModel =
                            { defaultModel
                                | netQuantityValidation = EmptyQuantity
                                , cpuQuantityValidation = EmptyQuantity
                                , isFormValid = False
                            }
                    in
                    Expect.equal expectedModel (validate defaultModel unstakePossibleCpu unstakePossibleNet)
            ]
        , describe "validateAttr"
            [ test "resourceQuantityStatus -> EmptyQuantity" <|
                \() ->
                    Expect.equal "" (validateAttr EmptyQuantity)
            , test "resourceQuantityStatus -> ValidQuantity" <|
                \() ->
                    Expect.equal "true" (validateAttr ValidQuantity)
            , test "resourceQuantityStatus -> OverValidQuantity " <|
                \() ->
                    Expect.equal "false" (validateAttr OverValidQuantity)
            , test "resourceQuantityStatus -> InvalidQuantity " <|
                \() ->
                    Expect.equal "false" (validateAttr InvalidQuantity)
            ]

        -- TODO(boseok):translation
        , describe "validateText"
            [ test "both EmptyQuantity" <|
                \() ->
                    let
                        defaultModel =
                            initModel

                        minimumResource =
                            defaultModel.minimumResource

                        expected =
                            ( "", "" )
                    in
                    Expect.equal expected (validateText Korean defaultModel)
            , test "cpu OverValidQuantity, net EmptyQuantity" <|
                \() ->
                    let
                        defaultModel =
                            { initModel
                                | cpuQuantityValidation = OverValidQuantity
                            }

                        minimumResource =
                            defaultModel.minimumResource

                        expected =
                            ( "언스테이크 가능한 CPU 수량을 초과하였습니다.", " false" )
                    in
                    Expect.equal expected (validateText Korean defaultModel)
            , test "cpu EmptyQuantity, net OverValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            { initModel
                                | netQuantityValidation = OverValidQuantity
                            }

                        minimumResource =
                            defaultModel.minimumResource

                        expected =
                            ( "언스테이크 가능한 NET 수량을 초과하였습니다.", " false" )
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

                        minimumResource =
                            defaultModel.minimumResource

                        expected =
                            ( "언스테이크 가능한 CPU 수량을 초과하였습니다.", " false" )
                    in
                    Expect.equal expected (validateText Korean defaultModel)
            , test "cpu ValidQuantity, net ValidQuantity" <|
                \() ->
                    let
                        defaultModel =
                            { initModel
                                | netQuantityValidation = ValidQuantity
                                , cpuQuantityValidation = ValidQuantity
                            }

                        minimumResource =
                            defaultModel.minimumResource

                        expected =
                            ( "언스테이크 가능합니다 :)", " true" )
                    in
                    Expect.equal expected (validateText Korean defaultModel)
            ]
        ]
