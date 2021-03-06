module Util.Formatter exposing
    ( assetAdd
    , assetSubtract
    , assetToFloat
    , deleteFromBack
    , eosAdd
    , eosSubtract
    , floatToAsset
    , formatAsset
    , formatSeconds
    , formatWithUsLocale
    , getDefaultAsset
    , getNow
    , getSymbolFromAsset
    , larimerToEos
    , numberWithinDigitLimit
    , percentageConverter
    , removeSymbolIfExists
    , resourceUnitConverter
    , timeFormatter
    , unitConverterRound2
    )

import Date.Extra as Date
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Regex exposing (contains, regex)
import Round
import Task
import Time exposing (Time)
import Util.Constant exposing (day, giga, hour, kilo, mega, millisec, minute, second, tera)
import Util.Token exposing (Token)


larimerToEos : Int -> Float
larimerToEos valInt =
    toFloat valInt * 0.0001


floatToAsset : Int -> String -> Float -> String
floatToAsset precision symbol val =
    Round.round precision val ++ " " ++ symbol


removeSymbolIfExists : String -> String
removeSymbolIfExists asset =
    asset
        |> String.split " "
        |> List.head
        |> Maybe.withDefault ""


assetToFloat : String -> Float
assetToFloat =
    removeSymbolIfExists
        >> String.toFloat
        >> Result.withDefault 0


assetAdd : String -> String -> Int -> String -> String
assetAdd a b precision symbol =
    assetToFloat a
        + assetToFloat b
        |> floatToAsset precision symbol


eosAdd : String -> String -> String
eosAdd a b =
    assetAdd a b 4 "EOS"


assetSubtract : String -> String -> Int -> String -> String
assetSubtract a b precision symbol =
    assetToFloat a
        - assetToFloat b
        |> floatToAsset precision symbol


eosSubtract : String -> String -> String
eosSubtract a b =
    assetSubtract a b 4 "EOS"



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
            if value < millisec then
                toString value ++ " us"

            else if (value >= millisec) && (value < second) then
                unitConverterRound2 value millisec ++ " ms"

            else if (value >= second) && (value < minute) then
                unitConverterRound2 value second ++ " s"

            else if (value >= minute) && (value < hour) then
                unitConverterRound2 value minute ++ " min"

            else if (value >= hour) && (value < day) then
                unitConverterRound2 value hour ++ " hour"

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


getNow : (Time -> msg) -> Cmd msg
getNow msg =
    Task.perform msg Time.now


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


numberWithinDigitLimit : Int -> String -> Bool
numberWithinDigitLimit digitLimit value =
    if contains (regex "^\\d+\\.\\d+$") value then
        let
            digitLength =
                String.split "." value |> List.drop 1 |> List.head |> Maybe.map String.length |> Maybe.withDefault 0
        in
        digitLength <= digitLimit

    else
        True


getDefaultAsset : Token -> String
getDefaultAsset { symbol, precision } =
    let
        base =
            if precision == 0 then
                "0"

            else
                "0." ++ String.repeat precision "0"
    in
    base ++ " " ++ symbol


getSymbolFromAsset : String -> Maybe String
getSymbolFromAsset asset =
    asset |> String.split " " |> List.drop 1 |> List.head


formatSeconds : Int -> String
formatSeconds seconds =
    if seconds > 3600 || seconds < 0 then
        "00:00"

    else
        let
            addZero str =
                if String.length str == 1 then
                    "0" ++ str

                else
                    str

            minuteStr =
                seconds // 60 |> toString |> addZero

            secondStr =
                (seconds % 60) |> toString |> addZero
        in
        minuteStr ++ ":" ++ secondStr
