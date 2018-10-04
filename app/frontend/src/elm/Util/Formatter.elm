module Util.Formatter exposing
    ( Message(..)
    , assetAdd
    , assetSubtract
    , assetToFloat
    , deleteFromBack
    , floatToAsset
    , formatAsset
    , formatWithUsLocale
    , getNow
    , larimerToEos
    , percentageConverter
    , removeSymbolIfExists
    , resourceUnitConverter
    , timeFormatter
    , unitConverterRound2
    )

import Date.Extra as Date
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Regex exposing (..)
import Round
import Task
import Time exposing (Time)
import Util.Constant exposing (day, giga, hour, kilo, mega, minute, second, tera)


type Message
    = OnTime Time.Time


larimerToEos : Int -> Float
larimerToEos valInt =
    toFloat valInt * 0.0001


floatToAsset : Float -> String
floatToAsset valFloat =
    Round.round 4 valFloat ++ " EOS"


removeSymbolIfExists : String -> String
removeSymbolIfExists asset =
    asset |> replace All (regex " EOS") (\_ -> "")


assetToFloat : String -> Float
assetToFloat str =
    let
        result =
            str
                |> removeSymbolIfExists
                |> String.toFloat
    in
    case result of
        Ok val ->
            val

        Err _ ->
            0


assetAdd : String -> String -> String
assetAdd a b =
    (+) (assetToFloat a)
        (assetToFloat b)
        |> floatToAsset


assetSubtract : String -> String -> String
assetSubtract a b =
    (-) (assetToFloat a)
        (assetToFloat b)
        |> floatToAsset



-- NOTE(boseok): if it needs other digit scales, then it shoud be changed like belows
-- getRoundedRatio : Int -> Int -> Int -> String
-- getRoundRatio numerator denominator digit(roundDigit)


unitConverterRound2 : Int -> Int -> String
unitConverterRound2 value unit =
    Round.round 2 (toFloat value / toFloat unit)


resourceUnitConverter : String -> Int -> String
resourceUnitConverter resourceType value =
    case resourceType of
        "net" ->
            -- Bytes
            if value < kilo then
                toString value ++ " bytes"
                -- KB

            else if (value >= kilo) && (value < mega) then
                unitConverterRound2 value kilo ++ " KB"
                -- MB

            else if (value >= mega) && (value < giga) then
                unitConverterRound2 value mega ++ " MB"
                -- GB

            else if (value >= giga) && (value < tera) then
                unitConverterRound2 value giga ++ " GB"
                -- TB

            else
                unitConverterRound2 value tera ++ " TB"

        "cpu" ->
            -- ms
            if value < second then
                toString value ++ " ms"
                -- second

            else if (value >= second) && (value < minute) then
                unitConverterRound2 value second ++ " s"
                -- minute

            else if (value >= minute) && (value < hour) then
                unitConverterRound2 value minute ++ " min"
                -- hour

            else if (value >= hour) && (value < day) then
                unitConverterRound2 value hour ++ " hour"
                -- day

            else
                unitConverterRound2 value day ++ " day"

        "ram" ->
            -- Bytes
            if value < 1024 then
                toString value ++ " bytes"
                -- KB

            else if (value >= kilo) && (value < mega) then
                unitConverterRound2 value kilo ++ " KB"
                -- MB

            else if (value >= mega) && (value < giga) then
                unitConverterRound2 value mega ++ " MB"
                -- GB

            else if (value >= giga) && (value < tera) then
                unitConverterRound2 value giga ++ " GB"
                -- TB

            else
                unitConverterRound2 value tera ++ " TB"

        _ ->
            ""


percentageConverter : Int -> Int -> Float
percentageConverter numerator denominator =
    toFloat (numerator * 100) / toFloat denominator


formatAsset : String -> String
formatAsset value =
    (value
        |> String.toFloat
        |> Result.withDefault 0
        |> Round.round 4
    )
        ++ " EOS"



-- Time


getNow : Cmd Message
getNow =
    Task.perform OnTime Time.now


timeFormatter : String -> String
timeFormatter time =
    case Date.fromIsoString (time ++ "+00:00") of
        Ok date ->
            Date.toFormattedString "HH:mm:ss YYYY/MM/dd" date

        Err str ->
            str



-- If the length of input string is less than digit, then return empty string.


deleteFromBack : Int -> String -> String
deleteFromBack digit string =
    let
        len =
            string |> String.length

        end =
            if digit > len then
                0

            else
                len - digit
    in
    String.slice 0 end string


formatWithUsLocale : Int -> Float -> String
formatWithUsLocale decimals value =
    value
        |> format { usLocale | decimals = decimals }
