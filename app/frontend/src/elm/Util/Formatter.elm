module Util.Formatter exposing (..)

import Round
import Regex exposing (..)
import Date.Extra as Date


larimerToEos : Int -> Float
larimerToEos valInt =
    (toFloat valInt) * 0.0001


eosFloatToString : Float -> String
eosFloatToString valFloat =
    (Round.round 4 valFloat) ++ " EOS"


eosStringToFloat : String -> Float
eosStringToFloat str =
    let
        result =
            str
                |> replace All (regex " EOS") (\_ -> "")
                |> String.toFloat
    in
        case result of
            Ok val ->
                val

            Err _ ->
                0


unitConverterRound4 : Int -> Int -> String
unitConverterRound4 value unit =
    Round.round 4 (toFloat value / toFloat unit)


percentageConverter : Int -> Int -> Float
percentageConverter numerator denominator =
    toFloat (numerator * 100) / toFloat denominator


formatEosQuantity : String -> String
formatEosQuantity =
    String.toFloat >> Result.withDefault 0 >> Round.round 4



-- Time


timeFormatter : String -> String
timeFormatter time =
    case Date.fromIsoString time of
        Ok date ->
            Date.toFormattedString "h:mm:ss a, MMMM, YYYY" date

        Err str ->
            str
