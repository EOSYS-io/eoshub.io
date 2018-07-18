module Page.Search exposing (Message(..), initModel, update, view)

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
        )
import Html.Attributes
    exposing
        ( placeholder
        , class
        , title
        , attribute
        , scope
        )
import Translation exposing (Language)
import Data.Account exposing (Account, ResourceInEos, Resource, Refund, accountDecoder, keyAccountsDecoder)


-- MODEL


initModel : Account
initModel =
    { account_name = ""
    , core_liquid_balance = "0 EOS"
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
        Just
            { net_weight = "0 EOS"
            , cpu_weight = "0 EOS"
            , ram_bytes = Nothing
            }
    , refund_request =
        Just
            { owner = ""
            , request_time = ""
            , net_amount = ""
            , cpu_amount = ""
            }
    }



-- UPDATE


type Message
    = Search


update : Message -> Account -> Account
update message model =
    case message of
        Search ->
            model



-- VIEW


view : Language -> Account -> Html Message
view _ model =
    section [ class "action view panel search_result" ]
        [ div [ class "account summary" ]
            [ ul [ class "summary" ]
                [ li []
                    [ text "계정이름                "
                    , strong [ title "chain.partners chain.partners" ]
                        [ text (model |> toString) ]
                    ]
                , li []
                    [ text "총 보유수량                 "
                    , strong []
                        [ text "4,502 EOS" ]
                    ]
                ]
            , ul [ class "details" ]
                [ li []
                    [ text "보관 안한 토큰                "
                    , strong []
                        [ text "120 EOS" ]
                    ]
                , li []
                    [ text "보관 취소 토큰                "
                    , strong []
                        [ text "400 EOS" ]
                    ]
                , li []
                    [ text "보관한 토큰                "
                    , strong []
                        [ text "10 EOS" ]
                    ]
                ]
            ]
        , h3 []
            [ text "리소스" ]
        , div [ class "resource" ]
            [ div [ class "cpu" ]
                [ h4 []
                    [ text "CPU                "
                    , strong []
                        [ text "778970655 ms Total" ]
                    ]
                , div [ class "graph" ]
                    [ span [ attribute "data-status" "high", attribute "style" "width:72%", title "CPU :72%" ]
                        []
                    ]
                , p []
                    [ text "사용 가능한 용량이 72% 남았어요" ]
                ]
            , div [ class "net" ]
                [ h4 []
                    [ text "NET                "
                    , strong []
                        [ text "141 MB Total" ]
                    ]
                , div [ class "graph" ]
                    [ span [ attribute "data-status" "middle", attribute "style" "width:50%", title "NET : 50%" ]
                        []
                    ]
                , p []
                    [ text "사용 가능한 용량이 32% 남았어요" ]
                ]
            , div [ class "ram" ]
                [ h4 []
                    [ text "RAM                "
                    , strong []
                        [ text "148290056 Bytes Total" ]
                    ]
                , div [ class "graph" ]
                    [ span [ attribute "data-status" "low", attribute "style" "width:12%", title "RAM : 12%" ]
                        []
                    ]
                , p []
                    [ text "사용 가능한 용량이 12% 남았어요" ]
                ]
            ]
        , div [ class "transaction_history" ]
            [ h3 []
                [ text "트랜잭션" ]
            , table []
                [ thead []
                    [ tr []
                        [ th [ scope "col" ]
                            [ text "type" ]
                        , th [ scope "col" ]
                            [ text "time" ]
                        , th [ scope "col" ]
                            [ text "info" ]
                        ]
                    ]
                , tbody []
                    [ tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    , tr []
                        [ td []
                            [ text "recieved" ]
                        , td []
                            [ text "8:06:36 AM, Apr 6, 2018" ]
                        , td []
                            [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                        ]
                    ]
                ]
            ]
        ]
