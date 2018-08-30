module Data.Account exposing (..)

import Html
    exposing
        ( Html
        , section
        , div
        , input
        , button
        , text
        , p
        , ul
        , li
        , text
        , strong
        , h3
        , h4
        , span
        , table
        , thead
        , tr
        , th
        , tbody
        , td
        , node
        , main_
        , h2
        , dl
        , dt
        , dd
        , br
        , select
        , option
        , em
        , caption
        )
import Html.Attributes
    exposing
        ( placeholder
        , class
        , title
        , attribute
        , type_
        , scope
        , hidden
        , name
        , value
        , id
        )
import Json.Decode as JD exposing (Decoder, at, oneOf)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Util.Formatter
    exposing
        ( larimerToEos
        , eosFloatToString
        , eosStringToFloat
        , unitConverterRound4
        , resourceUnitConverter
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
    , ram_bytes : Int
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
        , ram_bytes = 0
        }
    , self_delegated_bandwidth =
        { net_weight = "0 EOS"
        , cpu_weight = "0 EOS"
        , ram_bytes = 0
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
    JD.oneOf [ intStringDecoder, JD.int ]


intStringDecoder : Decoder Int
intStringDecoder =
    JD.map
        (\str ->
            case (String.toInt str) of
                Ok value ->
                    value

                Err str ->
                    0
        )
        JD.string



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


getResource : String -> Int -> Int -> Int -> ( String, String, String, String, String )
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
                    "hell"

                (-1) ->
                    "fine"

                _ ->
                    let
                        percentage =
                            percentageConverter available max
                    in
                        if percentage < 10 then
                            "hell"
                        else if percentage >= 10 && percentage < 30 then
                            "bad"
                        else if percentage >= 30 && percentage < 100 then
                            "good"
                        else
                            "fine"
    in
        ( usedString, availableString, totalString, avaliablePercent, color )
