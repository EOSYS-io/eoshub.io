module Test.Component.Main.Page.Search exposing (tests)

import Component.Main.Page.Search
    exposing
        ( actionCategory
        , actionHidden
        , filterDelbandWithAccountName
        , initModel
        , sumStakedToList
        , viewActionData
        )
import Data.Table exposing (..)
import Expect
import Html
    exposing
        ( b
        , br
        , td
        , text
        )
import Test exposing (..)


tests : Test
tests =
    let
        defaultAccount =
            initModel "eosyscommuni"

        defaultDelbandTable =
            [ Delband
                { from = "eosyscommuni"
                , receiver = "eosyscommuni"
                , netWeight = "0.7515 EOS"
                , cpuWeight = "0.7520 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "lievinkeosys"
                , netWeight = "0.1000 EOS"
                , cpuWeight = "0.1000 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "podopodopodo"
                , netWeight = "0.0001 EOS"
                , cpuWeight = "0.0001 EOS"
                }
            , Delband
                { from = "eosyscommuni"
                , receiver = "ramfuturesio"
                , netWeight = "0.0001 EOS"
                , cpuWeight = "0.0001 EOS"
                }
            ]

        defaultFilter =
            "eosyscommuni"
    in
    -- TODO(boseok): Add the getLeftTime test
    describe "Page.Search module"
        [ describe "utility functions"
            [ test "filterDelbandWithAccountName" <|
                \() ->
                    let
                        expected =
                            [ Delband
                                { from = "eosyscommuni"
                                , receiver = "lievinkeosys"
                                , netWeight = "0.1000 EOS"
                                , cpuWeight = "0.1000 EOS"
                                }
                            , Delband
                                { from = "eosyscommuni"
                                , receiver = "podopodopodo"
                                , netWeight = "0.0001 EOS"
                                , cpuWeight = "0.0001 EOS"
                                }
                            , Delband
                                { from = "eosyscommuni"
                                , receiver = "ramfuturesio"
                                , netWeight = "0.0001 EOS"
                                , cpuWeight = "0.0001 EOS"
                                }
                            ]
                    in
                    Expect.equal expected (filterDelbandWithAccountName defaultFilter defaultDelbandTable)
            , test "sumStakedToList" <|
                \() ->
                    Expect.equal "0.2004 EOS" (sumStakedToList defaultDelbandTable defaultFilter)
            , describe "actionHidden"
                [ test "transfer, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "transfer" "transfer")
                , test "transfer, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "transfer" "not transfer")
                , test "claimrewards, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "claimrewards" "claimrewards")
                , test "claimrewards, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "claimrewards" "not claimrewards")
                , test "ram, buyram, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" "buyram")
                , test "ram, buyrambytes hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" "buyrambytes")
                , test "ram, sellram hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "ram" "sellram")
                , test "ram, not ram, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "ram" "not ram")
                , test "resource, delegatebw, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "resource" "delegatebw")
                , test "resource, undelegatebw hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "resource" "undelegatebw")
                , test "resource, not resource, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "resource" "not resource")
                , test "regproxy, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "regproxy" "regproxy")
                , test "regproxy, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "regproxy" "not regproxy")
                , test "voteproducer, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "voteproducer" "voteproducer")
                , test "voteproducer, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "voteproducer" "not voteproducer")
                , test "newaccount, hidden False" <|
                    \() ->
                        Expect.equal False (actionHidden "newaccount" "newaccount")
                , test "newaccount, hidden True" <|
                    \() ->
                        Expect.equal True (actionHidden "newaccount" "not newaccount")
                ]
            ]
        , describe "view"
            [ describe "viewActionData"
                [ test "json, without \\\"" <|
                    \_ ->
                        let
                            data =
                                "{\"message\":\"BetDice Telegram Reward Round 2 has begun! Play, submit your transaction(TX) on Telegram, and receive free DICE based on your wager! t.me/betdice\"}"

                            expected =
                                [ b []
                                    [ text "message: " ]
                                , text "BetDice Telegram Reward Round 2 has begun! Play, submit your transaction(TX) on Telegram, and receive free DICE based on your wager! t.me/betdice\""
                                , br []
                                    []
                                ]
                        in
                        Expect.equal (toString expected) (toString (viewActionData data))
                , test "json, with \\\"" <|
                    \_ ->
                        let
                            data =
                                "{\"u\":\"eosyskoreabp\",\"msg\":\"✏ The XPET version of the WORLD CONQUEST \\\"X hegemony\\\" was already live, there is no loser game, the ultimate award + bancor token + pet dividends, each territory is extremely valuable, challenge the final conqueror, take away the 1000eos ancestor beast.  https://www.xpet.io/xmap.html\"}"

                            expected =
                                [ b []
                                    [ text "u: " ]
                                , text "eosyskoreabp"
                                , br []
                                    []
                                , b []
                                    [ text "msg: " ]
                                , text "✏ The XPET version of the WORLD CONQUEST \\\"X hegemony\\\" was already live, there is no loser game, the ultimate award + bancor token + pet dividends, each territory is extremely valuable, challenge the final conqueror, take away the 1000eos ancestor beast.  https://www.xpet.io/xmap.html\""
                                , br []
                                    []
                                ]
                        in
                        Expect.equal (toString expected) (toString (viewActionData data))
                ]
            ]
        ]
