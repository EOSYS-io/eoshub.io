module Test.Data.Action exposing (tests)

import Data.Action exposing (..)
import Expect
import Json.Decode as JD
import Test exposing (..)


tests : Test
tests =
    let
        defaultActions =
            [ { globalSequence = 1380
              , blockNum = 20277073
              , blockTime = "2018-10-07T03:16:10.500"
              , contractAccount = "eosio"
              , actionName = "claimrewards"
              , data =
                    Ok
                        (Claimrewards
                            { owner = "eosyskoreabp"
                            }
                        )
              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
              , actionTag = ""
              }
            , { globalSequence = 1381
              , blockNum = 20277073
              , blockTime = "2018-10-07T03:16:10.500"
              , contractAccount = "eosio.token"
              , actionName = "transfer"
              , data =
                    Ok
                        (Transfer "eosio.token"
                            { from = "eosio.vpay"
                            , to = "eosyskoreabp"
                            , quantity = "289.4270 EOS"
                            , memo = "producer vote pay"
                            }
                        )
              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
              , actionTag = ""
              }
            , { globalSequence = 1382
              , blockNum = 20277073
              , blockTime = "2018-10-07T03:16:10.500"
              , contractAccount = "eosio.token"
              , actionName = "transfer"
              , data =
                    Ok
                        (Transfer "eosio.token"
                            { from = "eosio.vpay"
                            , to = "eosyskoreabp"
                            , quantity = "289.4270 EOS"
                            , memo = "producer vote pay"
                            }
                        )
              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
              , actionTag = ""
              }
            , { globalSequence = 1383
              , blockNum = 20277073
              , blockTime = "2018-10-07T03:16:10.500"
              , contractAccount = "eosio.token"
              , actionName = "transfer"
              , data =
                    Ok
                        (Transfer "eosio.token"
                            { from = "eosio.vpay"
                            , to = "eosyskoreabp"
                            , quantity = "289.4270 EOS"
                            , memo = "producer vote pay"
                            }
                        )
              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
              , actionTag = ""
              }
            ]
    in
    describe "Data.Action module"
        [ describe "utility functions"
            [ test "removeDuplicated" <|
                \() ->
                    let
                        expected =
                            [ { globalSequence = 1380
                              , blockNum = 20277073
                              , blockTime = "2018-10-07T03:16:10.500"
                              , contractAccount = "eosio"
                              , actionName = "claimrewards"
                              , data =
                                    Ok
                                        (Claimrewards
                                            { owner = "eosyskoreabp"
                                            }
                                        )
                              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
                              , actionTag = ""
                              }
                            , { globalSequence = 1381
                              , blockNum = 20277073
                              , blockTime = "2018-10-07T03:16:10.500"
                              , contractAccount = "eosio.token"
                              , actionName = "transfer"
                              , data =
                                    Ok
                                        (Transfer "eosio.token"
                                            { from = "eosio.vpay"
                                            , to = "eosyskoreabp"
                                            , quantity = "289.4270 EOS"
                                            , memo = "producer vote pay"
                                            }
                                        )
                              , trxId = "8a982d35c204c68ca2a6e3e16b94e4be980283bcc8923422dc52988868488f70"
                              , actionTag = ""
                              }
                            ]
                    in
                    Expect.equal expected (removeDuplicated defaultActions)
            ]
        ]
