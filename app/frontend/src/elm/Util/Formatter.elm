module Util.Formatter exposing
    ( assetAdd
    , assetSubtract
    , assetToFloat
    , deleteFromBack
    , floatToAsset
    , formatAsset
    , formatWithUsLocale
    , larimerToEos
    , percentageConverter
    , removeSymbolIfExists
    , resourceUnitConverter
    , timeFormatter
    , unitConverterRound4
    )

import Date.Extra as Date
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (usLocale)
import Regex exposing (..)
import Round
import Translation exposing (Language(..))
import Util.Constant exposing (day, giga, hour, kilo, mega, minute, second, tera)


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


unitConverterRound4 : Int -> Int -> String
unitConverterRound4 value unit =
    Round.round 4 (toFloat value / toFloat unit)


resourceUnitConverter : String -> Int -> String
resourceUnitConverter resourceType value =
    case resourceType of
        "net" ->
            -- Bytes
            if value < kilo then
                toString value ++ " bytes"
                -- KB

            else if (value >= kilo) && (value < mega) then
                unitConverterRound4 value kilo ++ " KB"
                -- MB

            else if (value >= mega) && (value < giga) then
                unitConverterRound4 value mega ++ " MB"
                -- GB

            else if (value >= giga) && (value < tera) then
                unitConverterRound4 value giga ++ " GB"
                -- TB

            else
                unitConverterRound4 value tera ++ " TB"

        "cpu" ->
            -- ms
            if value < second then
                toString value ++ " ms"
                -- second

            else if (value >= second) && (value < minute) then
                unitConverterRound4 value second ++ " s"
                -- minute

            else if (value >= minute) && (value < hour) then
                unitConverterRound4 value minute ++ " min"
                -- hour

            else if (value >= hour) && (value < day) then
                unitConverterRound4 value hour ++ " hour"
                -- day

            else
                unitConverterRound4 value day ++ " day"

        "ram" ->
            -- Bytes
            if value < 1024 then
                toString value ++ " bytes"
                -- KB

            else if (value >= kilo) && (value < mega) then
                unitConverterRound4 value kilo ++ " KB"
                -- MB

            else if (value >= mega) && (value < giga) then
                unitConverterRound4 value mega ++ " MB"
                -- GB

            else if (value >= giga) && (value < tera) then
                unitConverterRound4 value giga ++ " GB"
                -- TB

            else
                unitConverterRound4 value tera ++ " TB"

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


timeFormatter : String -> String
timeFormatter time =
    case Date.fromIsoString time of
        Ok date ->
            Date.toFormattedString "YYYY/MM/dd HH:mm:ss" date

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
