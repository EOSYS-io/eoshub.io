module Data.Account exposing (..)

import Json.Decode as JD exposing (Decoder, at)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Util.Formatter
    exposing
        ( larimerToEos
        , eosFloatToString
        , eosStringToFloat
        , unitConverterRound4
        , percentageConverter
        )
import Util.Constant exposing (second, minute, hour, day, kilo, mega, giga, tera)
import Round


type alias Account =
    { account_name : String
    , core_liquid_balance : String
    , voter_info : VoterInfo
    , ram_quota : Int
    , ram_usage : Int
    , net_limit : Resource
    , cpu_limit : Resource
    , total_resources : ResourceInEos
    , self_delegated_bandwidth : ResourceInEos
    , refund_request : Refund
    }


type alias ResourceInEos =
    { net_weight : String
    , cpu_weight : String
    , ram_bytes : Maybe Int
    }


type alias Resource =
    { used : Int
    , available : Int
    , max : Int
    }


type alias Refund =
    { owner : String
    , request_time : String
    , net_amount : String
    , cpu_amount : String
    }


type alias VoterInfo =
    { staked : Int
    }


defaultAccount : Account
defaultAccount =
    { account_name = "Loading..."
    , core_liquid_balance = "0 EOS"
    , voter_info =
        { staked = 0 }
    , ram_quota = 0
    , ram_usage = 0
    , net_limit =
        { used = 0, available = 0, max = 0 }
    , cpu_limit =
        { used = 0, available = 0, max = 0 }
    , total_resources =
        { net_weight = "0 EOS"
        , cpu_weight = "0 EOS"
        , ram_bytes = Just 0
        }
    , self_delegated_bandwidth =
        { net_weight = "0 EOS"
        , cpu_weight = "0 EOS"
        , ram_bytes = Nothing
        }
    , refund_request =
        { owner = ""
        , request_time = ""
        , net_amount = "0 EOS"
        , cpu_amount = "0 EOS"
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
            )
            (VoterInfo 0)
        |> required "ram_quota" JD.int
        |> required "ram_usage" JD.int
        |> required "net_limit"
            (decode Resource
                |> required "used" JD.int
                |> required "available" JD.int
                |> required "max" JD.int
            )
        |> required "cpu_limit"
            (decode Resource
                |> required "used" JD.int
                |> required "available" JD.int
                |> required "max" JD.int
            )
        |> optional "total_resources"
            (decode ResourceInEos
                |> required "net_weight" JD.string
                |> required "cpu_weight" JD.string
                |> required "ram_bytes" (JD.nullable JD.int)
            )
            (ResourceInEos "0 EOS" "0 EOS" Nothing)
        |> optional "self_delegated_bandwidth"
            (decode ResourceInEos
                |> required "net_weight" JD.string
                |> required "cpu_weight" JD.string
                |> optional "ram_bytes" (JD.nullable JD.int) Nothing
            )
            (ResourceInEos "0 EOS" "0 EOS" Nothing)
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



-- Total Amount = core_liquid_balance + (staked * 0.0001) + (unstaking_net_amount + unstaking_cpu_amount)


getTotalAmount : String -> Int -> String -> String -> String
getTotalAmount core_liquid_balance staked unstaking_net_amount unstaking_cpu_amount =
    (eosStringToFloat core_liquid_balance
        + larimerToEos staked
        + eosStringToFloat unstaking_net_amount
        + eosStringToFloat unstaking_cpu_amount
        |> Round.round 4
    )
        ++ " EOS"


getUnstakingAmount : String -> String -> String
getUnstakingAmount unstaking_net_amount unstaking_cpu_amount =
    eosFloatToString (eosStringToFloat unstaking_net_amount + eosStringToFloat unstaking_cpu_amount)



-- getResource ( cpu/net, used, available, max ) -> ( totalString, avaliablePercent )


getResource : String -> Int -> Int -> Int -> ( String, String, String )
getResource resourceType used available max =
    let
        totalString =
            case max of
                (-1) ->
                    "unlimit"

                _ ->
                    case resourceType of
                        "net" ->
                            -- Bytes
                            if max < kilo then
                                toString max ++ " bytes"
                                -- KB
                            else if (max >= kilo) && (max < mega) then
                                unitConverterRound4 max kilo ++ " KB"
                                -- MB
                            else if (max >= mega) && (max < giga) then
                                unitConverterRound4 max mega ++ " MB"
                                -- GB
                            else if (max >= giga) && (max < tera) then
                                unitConverterRound4 max giga ++ " GB"
                                -- TB
                            else
                                unitConverterRound4 max tera ++ " TB"

                        "cpu" ->
                            -- ms
                            if max < second then
                                toString max ++ " ms"
                                -- second
                            else if (max >= second) && (max < minute) then
                                unitConverterRound4 max second ++ " s"
                                -- minute
                            else if (max >= minute) && (max < hour) then
                                unitConverterRound4 max minute ++ " min"
                                -- hour
                            else if (max >= hour) && (max < day) then
                                unitConverterRound4 max hour ++ " hour"
                                -- day
                            else
                                unitConverterRound4 max day ++ " day"

                        "ram" ->
                            -- Bytes
                            if max < 1024 then
                                toString max ++ " bytes"
                                -- KB
                            else if (max >= kilo) && (max < mega) then
                                unitConverterRound4 max kilo ++ " KB"
                                -- MB
                            else if (max >= mega) && (max < giga) then
                                unitConverterRound4 max mega ++ " MB"
                                -- GB
                            else if (max >= giga) && (max < tera) then
                                unitConverterRound4 max giga ++ " GB"
                                -- TB
                            else
                                unitConverterRound4 max tera ++ " TB"

                        _ ->
                            ""

        avaliablePercent =
            case max of
                0 ->
                    "0%"

                (-1) ->
                    "100%"

                _ ->
                    (percentageConverter available max |> Round.round 2) ++ "%"

        color =
            case max of
                0 ->
                    "hell"

                (-1) ->
                    "fine"

                _ ->
                    let
                        percentage =
                            percentageConverter available max
                    in
                        if percentage < 25 then
                            "hell"
                        else if percentage >= 25 && percentage < 50 then
                            "bad"
                        else if percentage >= 50 && percentage < 75 then
                            "good"
                        else
                            "fine"
    in
        ( totalString, avaliablePercent, color )
