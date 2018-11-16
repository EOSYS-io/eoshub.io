module Util.HttpRequest exposing
    ( getAccount
    , getActions
    , getEosAccountProduct
    , getFullPath
    , getTableRows
    , post
    )

import Data.Account exposing (Account, accountDecoder)
import Data.Action exposing (Action, actionsDecoder)
import Data.Json exposing (Product, productDecoder)
import Data.Table exposing (Row, rowsDecoder)
import Http
import Json.Decode exposing (Decoder)
import Json.Encode as Encode
import Translation exposing (Language, toLocale)
import Util.Flags exposing (Flags)
import Util.Urls exposing (eosAccountProductUrl, mainnetHistoryUrl, mainnetRpcUrl)


getFullPath : String -> String
getFullPath path =
    mainnetRpcUrl ++ path


post : String -> Http.Body -> Decoder a -> Http.Request a
post url body decoder =
    Http.request
        { method = "POST"
        , headers = []
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


getAccount : String -> Http.Request Account
getAccount accountName =
    let
        body =
            [ ( "account_name", accountName |> Encode.string ) ]
                |> Encode.object
                |> Http.jsonBody
    in
    post (getFullPath "/v1/chain/get_account") body accountDecoder


getActions : String -> Int -> Int -> Http.Request (List Action)
getActions query skip limit =
    Http.get
        (mainnetHistoryUrl
            ++ "/v1/history/get_actions/"
            ++ query
            ++ "?skip="
            ++ toString skip
            ++ "&limit="
            ++ toString limit
        )
        actionsDecoder



-- NOTE(boseok): limit: -1 means 'fetch all without limit'


getTableRows : String -> String -> String -> Int -> Http.Request (List Row)
getTableRows code scope table limit =
    let
        requestBody =
            [ ( "code", code |> Encode.string )
            , ( "scope", scope |> Encode.string )
            , ( "table", table |> Encode.string )
            , ( "json", True |> Encode.bool )
            , ( "limit", limit |> Encode.int )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/chain/get_table_rows" |> getFullPath) requestBody rowsDecoder


getEosAccountProduct : Flags -> Language -> Http.Request Product
getEosAccountProduct flags language =
    let
        url =
            eosAccountProductUrl flags (toLocale language)
    in
    Http.get url productDecoder
