module Data.Account exposing
    ( Account
    , AccountPerm
    , KeyPerm
    , Permission
    , PermissionShortened
    , Refund
    , RequiredAuth
    , Resource
    , ResourceInEos
    , VoterInfo
    , accountDecoder
    , defaultAccount
    , getResource
    , getResourceColorClass
    , getTotalAmount
    , getUnstakingAmount
    , intOrStringDecoder
    , integerStringDecoder
    , keyAccountsDecoder
    )

import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Round
import Util.Formatter
    exposing
        ( assetToFloat
        , eosAdd
        , larimerToEos
        , percentageConverter
        , resourceUnitConverter
        )


type alias Account =
    { accountName : String
    , coreLiquidBalance : String
    , voterInfo : VoterInfo
    , ramQuota : Int
    , ramUsage : Int
    , netLimit : Resource
    , cpuLimit : Resource
    , permissions : List Permission
    , totalResources : ResourceInEos
    , selfDelegatedBandwidth : ResourceInEos
    , refundRequest : Refund
    }


type alias ResourceInEos =
    { netWeight : String
    , cpuWeight : String
    , ramBytes : Int
    }


type alias Resource =
    { used : Int
    , available : Int
    , max : Int
    }


type alias Permission =
    { permName : String
    , parent : String
    , requiredAuth : RequiredAuth
    }


type alias RequiredAuth =
    { threshold : Int
    , keys : List KeyPerm
    , accounts : List AccountPerm
    }


type alias KeyPerm =
    { key : String
    , weight : Int
    }


type alias AccountPerm =
    { permission : PermissionShortened
    , weight : Int
    }


type alias PermissionShortened =
    { actor : String
    , permission : String
    }


type alias Refund =
    { owner : String
    , requestTime : String
    , netAmount : String
    , cpuAmount : String
    }


type alias VoterInfo =
    { staked : Int
    , producers : List String
    }


defaultAccount : Account
defaultAccount =
    { accountName = ""
    , coreLiquidBalance = "0 EOS"
    , voterInfo =
        { staked = 0
        , producers = []
        }
    , ramQuota = 0
    , ramUsage = 0
    , netLimit =
        { used = 0, available = 0, max = 0 }
    , cpuLimit =
        { used = 0, available = 0, max = 0 }
    , permissions = []
    , totalResources =
        { netWeight = "0 EOS"
        , cpuWeight = "0 EOS"
        , ramBytes = 0
        }
    , selfDelegatedBandwidth =
        { netWeight = "0 EOS"
        , cpuWeight = "0 EOS"
        , ramBytes = 0
        }
    , refundRequest =
        { owner = ""
        , requestTime = ""
        , netAmount = "0 EOS"
        , cpuAmount = "0 EOS"
        }
    }


accountDecoder : JD.Decoder Account
accountDecoder =
    decode Account
        |> required "account_name" JD.string
        |> optional "core_liquid_balance" JD.string "0 EOS"
        |> optional "voter_info"
            (decode VoterInfo
                |> required "staked" JD.int
                |> required "producers" (JD.list JD.string)
            )
            (VoterInfo 0 [])
        |> required "ram_quota" intOrStringDecoder
        |> required "ram_usage" intOrStringDecoder
        |> required "net_limit"
            (decode Resource
                |> required "used" intOrStringDecoder
                |> required "available" intOrStringDecoder
                |> required "max" intOrStringDecoder
            )
        |> required "cpu_limit"
            (decode Resource
                |> required "used" intOrStringDecoder
                |> required "available" intOrStringDecoder
                |> required "max" intOrStringDecoder
            )
        |> required "permissions"
            (JD.list
                (decode Permission
                    |> required "perm_name" JD.string
                    |> required "parent" JD.string
                    |> required "required_auth"
                        (decode RequiredAuth
                            |> required "threshold" JD.int
                            |> required "keys"
                                (JD.list
                                    (decode KeyPerm
                                        |> required "key" JD.string
                                        |> required "weight" JD.int
                                    )
                                )
                            |> required "accounts"
                                (JD.list
                                    (decode AccountPerm
                                        |> required "permission"
                                            (decode PermissionShortened
                                                |> required "actor" JD.string
                                                |> required "permission" JD.string
                                            )
                                        |> required "weight" JD.int
                                    )
                                )
                        )
                )
            )
        |> optional "total_resources"
            (decode ResourceInEos
                |> required "net_weight" JD.string
                |> required "cpu_weight" JD.string
                |> optional "ram_bytes" intOrStringDecoder 0
            )
            (ResourceInEos "0 EOS" "0 EOS" 0)
        |> optional "self_delegated_bandwidth"
            (decode ResourceInEos
                |> required "net_weight" JD.string
                |> required "cpu_weight" JD.string
                |> optional "ram_bytes" intOrStringDecoder 0
            )
            (ResourceInEos "0 EOS" "0 EOS" 0)
        |> optional "refund_request"
            (decode Refund
                |> required "owner" JD.string
                |> required "request_time" JD.string
                |> required "net_amount" JD.string
                |> required "cpu_amount" JD.string
            )
            (Refund "" "" "0 EOS" "0 EOS")


keyAccountsDecoder : JD.Decoder (List String)
keyAccountsDecoder =
    JD.field "account_names" (JD.list JD.string)


intOrStringDecoder : Decoder Int
intOrStringDecoder =
    JD.oneOf [ integerStringDecoder, JD.int ]



-- NOTE(boseok): integerString - format is 'number', type is String


integerStringDecoder : Decoder Int
integerStringDecoder =
    JD.map
        (\str ->
            case String.toInt str of
                Ok value ->
                    value

                Err _ ->
                    0
        )
        JD.string



-- Total Amount = core_liquid_balance + (staked * 0.0001) + (unstaking_net_amount + unstaking_cpu_amount)


getTotalAmount : String -> Int -> String -> String -> String
getTotalAmount coreLiquidBalance staked unstakingNetAmount unstakingCpuAmount =
    (assetToFloat coreLiquidBalance
        + larimerToEos staked
        + assetToFloat unstakingNetAmount
        + assetToFloat unstakingCpuAmount
        |> Round.round 4
    )
        ++ " EOS"


getUnstakingAmount : String -> String -> String
getUnstakingAmount unstakingNetAmount unstakingCpuAmount =
    eosAdd unstakingNetAmount unstakingCpuAmount


getResource : String -> Int -> Int -> Int -> ( String, String, String, String, Int )
getResource resourceType used available max =
    let
        -- NOTE(boseok): there's no ram available field, so calculate it by (available = max - used).
        -- but when available is less than 0 (unlimited case), available needs to be just -1
        availableMinusCase =
            if available < 0 then
                -1

            else
                available

        totalString =
            case max of
                (-1) ->
                    "unlimit"

                _ ->
                    resourceUnitConverter resourceType max

        usedString =
            case used of
                (-1) ->
                    "unlimit"

                _ ->
                    resourceUnitConverter resourceType used

        availableString =
            case availableMinusCase of
                (-1) ->
                    "unlimit"

                _ ->
                    resourceUnitConverter resourceType availableMinusCase

        avaliablePercent =
            case max of
                0 ->
                    "0%"

                (-1) ->
                    "100%"

                _ ->
                    let
                        value =
                            (percentageConverter available max |> Round.round 2) ++ "%"
                    in
                    if value == "100.00%" then
                        "100%"

                    else
                        value

        color =
            case max of
                0 ->
                    1

                (-1) ->
                    4

                _ ->
                    let
                        percentage =
                            percentageConverter available max
                    in
                    if percentage < 10 then
                        1

                    else if percentage >= 10 && percentage < 30 then
                        2

                    else if percentage >= 30 && percentage < 100 then
                        3

                    else
                        4
    in
    ( usedString, availableString, totalString, avaliablePercent, color )


getResourceColorClass : Int -> String
getResourceColorClass code =
    case code of
        1 ->
            "hell"

        2 ->
            "bad"

        3 ->
            "good"

        4 ->
            "fine"

        _ ->
            ""
