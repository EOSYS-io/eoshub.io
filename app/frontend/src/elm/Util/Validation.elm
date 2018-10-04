module Util.Validation exposing
    ( AccountStatus(..)
    , MemoStatus(..)
    , QuantityStatus(..)
    , VerificationRequestStatus(..)
    , checkAccountName
    , checkConfirmToken
    , isAccount
    , isPublicKey
    , validateAccount
    , validateMemo
    , validateQuantity
    )

import Regex exposing (..)
import String.UTF8 as UTF8
import Util.Formatter exposing (removeSymbolIfExists)


isAccount : String -> Bool
isAccount query =
    contains (regex "^[a-z.1-5]{1,12}$") query


isPublicKey : String -> Bool
isPublicKey query =
    contains (regex "^EOS[\\w]{50}$") query


checkAccountName : String -> Bool
checkAccountName query =
    contains (regex "^[a-z.1-5]{12,12}$") query


checkConfirmToken : String -> Bool
checkConfirmToken query =
    contains (regex "^[a-zA-Z0-9_-]{22}$") query



-- form validate


type AccountStatus
    = EmptyAccount
    | ValidAccount
    | InexistentAccount
    | InvalidAccount
    | AccountToBeVerified


type VerificationRequestStatus
    = Succeed
    | Fail
    | NotSent


type QuantityStatus
    = EmptyQuantity
    | OverValidQuantity
    | InvalidQuantity
    | ValidQuantity


type MemoStatus
    = MemoTooLong
    | EmptyMemo
    | ValidMemo


validateAccount : String -> VerificationRequestStatus -> AccountStatus
validateAccount accountName requestStatus =
    if accountName == "" then
        EmptyAccount

    else if isAccount accountName then
        case requestStatus of
            Succeed ->
                ValidAccount

            Fail ->
                InexistentAccount

            NotSent ->
                AccountToBeVerified

    else
        InvalidAccount



-- NOTE(boseok): "1.0000", "1.0000 EOS" both cases can be validated


validateQuantity : String -> Float -> QuantityStatus
validateQuantity quantity maxAmount =
    if quantity == "" then
        EmptyQuantity

    else
        let
            maybeQuantity =
                quantity
                    |> removeSymbolIfExists
                    |> String.toFloat
        in
        case maybeQuantity of
            Ok quantity ->
                if quantity <= 0 then
                    InvalidQuantity

                else if quantity > maxAmount then
                    OverValidQuantity

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
