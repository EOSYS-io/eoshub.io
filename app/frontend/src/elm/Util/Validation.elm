module Util.Validation exposing (..)

import Regex exposing (regex, contains)
import String.UTF8 as UTF8


isAccount : String -> Bool
isAccount query =
    contains (regex "^[a-z.1-5]{1,12}$") query


isPublicKey : String -> Bool
isPublicKey query =
    contains (regex "^EOS[\\w]{50}$") query


checkAccountName : String -> Bool
checkAccountName query =
    contains (regex "^[a-z.1-5]{12,12}$") query



-- form validate


type AccountStatus
    = EmptyAccount
    | ValidAccount
    | InvalidAccount


type QuantityStatus
    = EmptyQuantity
    | OverTransferableQuantity
    | InvalidQuantity
    | ValidQuantity


type MemoStatus
    = MemoTooLong
    | EmptyMemo
    | ValidMemo


validateAccount : String -> AccountStatus
validateAccount accountName =
    if accountName == "" then
        EmptyAccount
    else if isAccount accountName then
        ValidAccount
    else
        InvalidAccount


validateQuantity : String -> Float -> QuantityStatus
validateQuantity quantity eosLiquidAmount =
    if quantity == "" then
        EmptyQuantity
    else
        let
            maybeQuantity =
                String.toFloat quantity
        in
            case maybeQuantity of
                Ok quantity ->
                    if quantity <= 0 then
                        InvalidQuantity
                    else if quantity > eosLiquidAmount then
                        OverTransferableQuantity
                    else
                        ValidQuantity

                _ ->
                    InvalidQuantity


validateMemo : String -> MemoStatus
validateMemo memo =
    if UTF8.length memo > 256 then
        MemoTooLong
    else
        ValidMemo
