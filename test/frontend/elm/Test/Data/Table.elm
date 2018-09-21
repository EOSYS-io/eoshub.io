module Test.Data.Table exposing (tests)

import Data.Table exposing (globalDecoder, rammarketDecoder, rowsDecoder, tokenStatDecoder)
import Expect
import Json.Decode as JD
import Test exposing (..)


tests : Test
tests =
    describe "decoders"
        (let
            rammarketTableRowJson =
                "{\"supply\":\"10000000000.0000 RAMCORE\",\"base\":{\"balance\":\"32404086104 RAM\",\"weight\":\"0.50000000000000000\"},\"quote\":{\"balance\":\"3277860.4027 EOS\",\"weight\":\"0.50000000000000000\"}}"

            globalTableRowJson =
                "{\"max_block_net_usage\":1048576,\"target_block_net_usage_pct\":1000,\"max_transaction_net_usage\":524288,\"base_per_transaction_net_usage\":12,\"net_usage_leeway\":500,\"context_free_discount_net_usage_num\":20,\"context_free_discount_net_usage_den\":100,\"max_block_cpu_usage\":200000,\"target_block_cpu_usage_pct\":1000,\"max_transaction_cpu_usage\":150000,\"min_transaction_cpu_usage\":100,\"max_transaction_lifetime\":3600,\"deferred_trx_expiration_window\":600,\"max_transaction_delay\":3888000,\"max_inline_action_size\":4096,\"max_inline_action_depth\":4,\"max_authority_depth\":6,\"max_ram_size\":\"78887812096\",\"total_ram_bytes_reserved\":\"46483229140\",\"total_ram_stake\":\"22778665983\",\"last_producer_schedule_update\":\"2018-09-12T12:26:54.000\",\"last_pervote_bucket_fill\":\"1536753735500000\",\"pervote_bucket\":204263384,\"perblock_bucket\":25479867,\"total_unpaid_blocks\":66724,\"total_activated_stake\":\"3820428429708\",\"thresh_activated_stake_time\":\"1529505892000000\",\"last_producer_schedule_size\":21,\"total_producer_vote_weight\":\"17108606383116546048.00000000000000000\",\"last_name_close\":\"2018-09-11T18:01:10.500\"}"

            tokenStatTableRowJson =
                "{\"supply\":\"1013180313.0669 EOS\",\"max_supply\":\"10000000000.0000 EOS\",\"issuer\":\"eosio\"}"

            expectedRammarketTableFields =
                { supply = "10000000000.0000 RAMCORE"
                , base =
                    { balance = "32404086104 RAM"
                    , weight = "0.50000000000000000"
                    }
                , quote =
                    { balance = "3277860.4027 EOS"
                    , weight = "0.50000000000000000"
                    }
                }

            expectedGlobalTableFields =
                { maxBlockNetUsage = 1048576
                , targetBlockNetUsagePct = 1000
                , maxTransactionNetUsage = 524288
                , basePerTransactionNetUsage = 12
                , netUsageLeeway = 500
                , contextFreeDiscountNetUsageNum = 20
                , contextFreeDiscountNetUsageDen = 100
                , maxBlockCpuUsage = 200000
                , targetBlockCpuUsagePct = 1000
                , maxTransactionCpuUsage = 150000
                , minTransactionCpuUsage = 100
                , maxTransactionLifetime = 3600
                , deferredTrxExpirationWindow = 600
                , maxTransactionDelay = 3888000
                , maxInlineActionSize = 4096
                , maxInlineActionDepth = 4
                , maxAuthorityDepth = 6
                , maxRamSize = "78887812096"
                , totalRamBytesReserved = "46483229140"
                , totalRamStake = "22778665983"
                , lastProducerScheduleUpdate = "2018-09-12T12:26:54.000"
                , lastPervoteBucketFill = "1536753735500000"
                , pervoteBucket = 204263384
                , perblockBucket = 25479867
                , totalUnpaidBlocks = 66724
                , totalActivatedStake = "3820428429708"
                , threshActivatedStakeTime = "1529505892000000"
                , lastProducerScheduleSize = 21
                , totalProducerVoteWeight = "17108606383116546048.00000000000000000"
                , lastNameClose = "2018-09-11T18:01:10.500"
                }

            expectedTokenStatTableFields =
                { supply = "1013180313.0669 EOS"
                , maxSupply = "10000000000.0000 EOS"
                , issuer = "eosio"
                }
         in
         [ describe "rowDecoder"
            [ test "rammarket" <|
                \() ->
                    Expect.equal
                        (Ok expectedRammarketTableFields)
                        (JD.decodeString rammarketDecoder rammarketTableRowJson)
            , test "global" <|
                \() ->
                    Expect.equal
                        (Ok expectedGlobalTableFields)
                        (JD.decodeString globalDecoder globalTableRowJson)
            , test "token stat" <|
                \() ->
                    Expect.equal
                        (Ok expectedTokenStatTableFields)
                        (JD.decodeString tokenStatDecoder tokenStatTableRowJson)
            ]
         , describe "rowsDecoder"
            [ test "rows" <|
                let
                    tableJson =
                        "{\"rows\":[" ++ rammarketTableRowJson ++ "],\"more\":true}"

                    rammarketRow =
                        Data.Table.Rammarket expectedRammarketTableFields
                in
                \() ->
                    Expect.equal
                        (Ok [ rammarketRow ])
                        (JD.decodeString rowsDecoder tableJson)
            ]
         ]
        )
