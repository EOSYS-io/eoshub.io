-- This module provides eosio blockchain table decoders.


module Data.Table exposing
    ( BalanceWeight
    , GlobalFields
    , RammarketFields
    , Row(..)
    , Table
    , balanceWeightDecoder
    , globalDecoder
    , initGlobalFields
    , initRammarketFields
    , rammarketDecoder
    , rowDecoder
    , rowsDecoder
    )

import Json.Decode as Decode exposing (Decoder, decodeString, oneOf)
import Json.Decode.Pipeline exposing (decode, required)


type alias Table =
    { rows : List Row
    , more : Bool
    }


type Row
    = Rammarket RammarketFields
    | Global GlobalFields


type alias BalanceWeight =
    { balance : String
    , weight : String
    }


type alias RammarketFields =
    { supply : String
    , base : BalanceWeight
    , quote : BalanceWeight
    }


initRammarketFields : RammarketFields
initRammarketFields =
    { supply = ""
    , base =
        { balance = ""
        , weight = ""
        }
    , quote =
        { balance = ""
        , weight = ""
        }
    }


type alias GlobalFields =
    { maxBlockNetUsage : Int
    , targetBlockNetUsagePct : Int
    , maxTransactionNetUsage : Int
    , basePerTransactionNetUsage : Int
    , netUsageLeeway : Int
    , contextFreeDiscountNetUsageNum : Int
    , contextFreeDiscountNetUsageDen : Int
    , maxBlockCpuUsage : Int
    , targetBlockCpuUsagePct : Int
    , maxTransactionCpuUsage : Int
    , minTransactionCpuUsage : Int
    , maxTransactionLifetime : Int
    , deferredTrxExpirationWindow : Int
    , maxTransactionDelay : Int
    , maxInlineActionSize : Int
    , maxInlineActionDepth : Int
    , maxAuthorityDepth : Int
    , maxRamSize : String
    , totalRamBytesReserved : String
    , totalRamStake : String
    , lastProducerScheduleUpdate : String
    , lastPervoteBucketFill : String
    , pervoteBucket : Int
    , perblockBucket : Int
    , totalUnpaidBlocks : Int
    , totalActivatedStake : String
    , threshActivatedStakeTime : String
    , lastProducerScheduleSize : Int
    , totalProducerVoteWeight : String
    , lastNameClose : String
    }


initGlobalFields : GlobalFields
initGlobalFields =
    { maxBlockNetUsage = 0
    , targetBlockNetUsagePct = 0
    , maxTransactionNetUsage = 0
    , basePerTransactionNetUsage = 0
    , netUsageLeeway = 0
    , contextFreeDiscountNetUsageNum = 0
    , contextFreeDiscountNetUsageDen = 0
    , maxBlockCpuUsage = 0
    , targetBlockCpuUsagePct = 0
    , maxTransactionCpuUsage = 0
    , minTransactionCpuUsage = 0
    , maxTransactionLifetime = 0
    , deferredTrxExpirationWindow = 0
    , maxTransactionDelay = 0
    , maxInlineActionSize = 0
    , maxInlineActionDepth = 0
    , maxAuthorityDepth = 0
    , maxRamSize = ""
    , totalRamBytesReserved = ""
    , totalRamStake = ""
    , lastProducerScheduleUpdate = ""
    , lastPervoteBucketFill = ""
    , pervoteBucket = 0
    , perblockBucket = 0
    , totalUnpaidBlocks = 0
    , totalActivatedStake = ""
    , threshActivatedStakeTime = ""
    , lastProducerScheduleSize = 0
    , totalProducerVoteWeight = ""
    , lastNameClose = ""
    }


rowsDecoder : Decoder (List Row)
rowsDecoder =
    Decode.field "rows"
        (Decode.list rowDecoder)


rowDecoder : Decoder Row
rowDecoder =
    oneOf
        [ Decode.map Rammarket rammarketDecoder
        , Decode.map Global globalDecoder
        ]


balanceWeightDecoder : Decoder BalanceWeight
balanceWeightDecoder =
    Decode.map2 BalanceWeight
        (Decode.field "balance" Decode.string)
        (Decode.field "weight" Decode.string)


rammarketDecoder : Decoder RammarketFields
rammarketDecoder =
    Decode.map3 RammarketFields
        (Decode.field "supply" Decode.string)
        (Decode.field "base" balanceWeightDecoder)
        (Decode.field "quote" balanceWeightDecoder)


globalDecoder : Decoder GlobalFields
globalDecoder =
    decode GlobalFields
        |> required "max_block_net_usage" Decode.int
        |> required "target_block_net_usage_pct" Decode.int
        |> required "max_transaction_net_usage" Decode.int
        |> required "base_per_transaction_net_usage" Decode.int
        |> required "net_usage_leeway" Decode.int
        |> required "context_free_discount_net_usage_num" Decode.int
        |> required "context_free_discount_net_usage_den" Decode.int
        |> required "max_block_cpu_usage" Decode.int
        |> required "target_block_cpu_usage_pct" Decode.int
        |> required "max_transaction_cpu_usage" Decode.int
        |> required "min_transaction_cpu_usage" Decode.int
        |> required "max_transaction_lifetime" Decode.int
        |> required "deferred_trx_expiration_window" Decode.int
        |> required "max_transaction_delay" Decode.int
        |> required "max_inline_action_size" Decode.int
        |> required "max_inline_action_depth" Decode.int
        |> required "max_authority_depth" Decode.int
        |> required "max_ram_size" Decode.string
        |> required "total_ram_bytes_reserved" Decode.string
        |> required "total_ram_stake" Decode.string
        |> required "last_producer_schedule_update" Decode.string
        |> required "last_pervote_bucket_fill" Decode.string
        |> required "pervote_bucket" Decode.int
        |> required "perblock_bucket" Decode.int
        |> required "total_unpaid_blocks" Decode.int
        |> required "total_activated_stake" Decode.string
        |> required "thresh_activated_stake_time" Decode.string
        |> required "last_producer_schedule_size" Decode.int
        |> required "total_producer_vote_weight" Decode.string
        |> required "last_name_close" Decode.string
