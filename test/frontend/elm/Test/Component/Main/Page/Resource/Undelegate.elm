module Test.Component.Main.Page.Resource.Undelegate exposing (tests)

import Component.Main.Page.Resource.Undelegate exposing (..)
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



-- TODO(boseok): tests for Undelegate.update


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
    describe "Page.Resource.Undelegate module"
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
        , describe "validate"
            [ describe "isAccountValid False"
                [ test "validate test0. receiver EmptyAccount, cpu ValidQuantity, net ValidQuantity" <|
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
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
                ]
            , describe "isAccountValid True"
                [ test "validate test1. cpu ValidQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | undelegatebw =
                                        { undelegatebw
                                            | receiver = "abcdabcdabcd"
                                            , unstakeCpuQuantity = "0.0600"
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , cpuQuantityValidation = ValidQuantity
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
                                            | receiver = "abcdabcdabcd"
                                            , unstakeNetQuantity = "0.0600"
                                            , unstakeCpuQuantity = ""
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , netQuantityValidation = ValidQuantity
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
                                            | receiver = "abcdabcdabcd"
                                            , unstakeNetQuantity = "0.0600"
                                            , unstakeCpuQuantity = "0.1000"
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , netQuantityValidation = ValidQuantity
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
                                            | receiver = "abcdabcdabcd"
                                            , unstakeNetQuantity = "1.0000"
                                            , unstakeCpuQuantity = "0.1000"
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , netQuantityValidation = OverValidQuantity
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
                                            | receiver = "abcdabcdabcd"
                                            , unstakeNetQuantity = "0.1000"
                                            , unstakeCpuQuantity = "1.1000"
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , netQuantityValidation = ValidQuantity
                                    , cpuQuantityValidation = OverValidQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
                , test "validate test6. cpu EmptyQuantity, net EmptyQuantity" <|
                    \() ->
                        let
                            newModel =
                                { defaultModel
                                    | undelegatebw =
                                        { undelegatebw
                                            | receiver = "abcdabcdabcd"
                                        }
                                }

                            expectedModel =
                                { newModel
                                    | accountValidation = ValidAccount
                                    , netQuantityValidation = EmptyQuantity
                                    , cpuQuantityValidation = EmptyQuantity
                                    , isFormValid = False
                                }
                        in
                        Expect.equal expectedModel (validate newModel unstakePossibleCpu unstakePossibleNet)
                ]
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

        -- TODO(boseok): validateText test. comment will be changed.
        ]
