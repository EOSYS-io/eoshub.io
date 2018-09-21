module Util.HttpRequest exposing (getAccount, getFullPath, getTableRows, post)

import Data.Account exposing (Account, accountDecoder)
import Data.Table exposing (Row, rowsDecoder)
import Http
import Json.Decode exposing (Decoder)
import Json.Encode as Encode
import Util.Urls exposing (mainnetRpcUrl)


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


getTableRows : String -> String -> String -> Http.Request (List Row)
getTableRows code scope table =
    let
        requestBody =
            [ ( "code", code |> Encode.string )
            , ( "scope", scope |> Encode.string )
            , ( "table", table |> Encode.string )
            , ( "json", True |> Encode.bool )
            ]
                |> Encode.object
                |> Http.jsonBody
    in
    post ("/v1/chain/get_table_rows" |> getFullPath) requestBody rowsDecoder
