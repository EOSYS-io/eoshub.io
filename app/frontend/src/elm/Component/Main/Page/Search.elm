module Component.Main.Page.Search exposing (..)

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
        )
import Html.Attributes
    exposing
        ( placeholder
        , class
        , title
        , attribute
        , type_
        , scope
        )
import Translation exposing (I18n(..), Language, translate)
import Http
import Util.HttpRequest exposing (..)
import Json.Encode as JE
import Data.Action exposing (Action)
import Data.Account exposing (Account, ResourceInEos, Resource, Refund, accountDecoder, keyAccountsDecoder)
import Regex exposing (..)
import Round


-- MODEL


type alias Model =
    { account : Account
    , actions : List Action
    }


initModel : Model
initModel =
    { account =
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
            , ram_bytes = Just 0
            }
        , self_delegated_bandwidth =
            { net_weight = "0 EOS"
            , cpu_weight = "0 EOS"
            , ram_bytes = Nothing
            }
        , refund_request =
            { owner = ""
            , request_time = ""
            , net_amount = "0 EOS"
            , cpu_amount = "0 EOS"
            }
        }
    , actions = []
    }


initCmd : String -> Cmd Message
initCmd query =
    let
        newCmd =
            let
                body =
                    JE.object
                        [ ( "account_name", JE.string query ) ]
                        |> Http.jsonBody
            in
                post (getFullPath "/v1/chain/get_account") body accountDecoder |> (Http.send OnFetchAccount)
    in
        newCmd


apiUrl : String
apiUrl =
    "https://rpc.eosys.io"



-- UPDATE


type Message
    = OnFetchAccount (Result Http.Error Account)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        -- GetSearchResult query ->
        --     let
        --         newCmd =
        --             let
        --                 body =
        --                     JE.object
        --                         [ ( "account_name", JE.string query ) ]
        --                         |> Http.jsonBody
        --             in
        --                 post (getFullPath "/v1/chain/get_account") body accountDecoder |> (Http.send OnFetchAccount)
        -- TODO(boseok): Move to searchkey page
        --         -- Ok PublicKeyQuery ->
        --         --     let
        --         --         body =
        --         --             JE.object
        --         --                 [ ( "public_key", JE.string query ) ]
        --         --                 |> Http.jsonBody
        --         --     in
        --         --         post (getFullPath "/v1/history/get_key_accounts") body keyAccountsDecoder |> (Http.send OnFetchKeyAccounts)
        --     in
        --         ( model, newCmd )
        OnFetchAccount (Ok data) ->
            ( { model | account = data }, Cmd.none )

        OnFetchAccount (Err error) ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> Html Message
view language { account } =
    let
        totalAmount =
            (getTotalAmount
                account.core_liquid_balance
                account.voter_info.staked
                account.refund_request.net_amount
                account.refund_request.cpu_amount
            )

        unstakingAmount =
            getUnstakingAmount account.refund_request.net_amount account.refund_request.cpu_amount

        stakedAmount =
            eosFloatToString (larimerToEos account.voter_info.staked)

        ( cpuTotal, cpuPercent, cpuColor ) =
            getResource "cpu" account.cpu_limit.used account.cpu_limit.available account.cpu_limit.max

        ( netTotal, netPercent, netColor ) =
            getResource "net" account.net_limit.used account.net_limit.available account.net_limit.max

        ( ramTotal, ramPercent, ramColor ) =
            getResource "ram" account.ram_usage (account.ram_quota - account.ram_usage) account.ram_quota
    in
        section [ class "action view panel search_result" ]
            [ div [ class "account summary" ]
                [ ul [ class "summary" ]
                    [ li []
                        [ text "계정이름                "
                        , strong [ title account.account_name ]
                            [ text account.account_name ]
                        ]
                    , li []
                        [ text (translate language TotalAmount)
                        , strong []
                            [ text totalAmount ]
                        ]
                    ]
                , ul [ class "details" ]
                    [ li []
                        [ text "보관 안한 토큰"
                        , strong []
                            [ text account.core_liquid_balance ]
                        ]
                    , li []
                        [ text "보관 취소 토큰                "
                        , strong []
                            [ text unstakingAmount ]
                        ]
                    , li []
                        [ text "보관한 토큰                "
                        , strong []
                            [ text stakedAmount ]
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
                            [ text (cpuTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span
                            [ attribute "data-status" cpuColor
                            , attribute "style"
                                ("width:" ++ cpuPercent)
                            , title
                                ("CPU :" ++ cpuPercent)
                            ]
                            []
                        ]
                    , p []
                        [ text
                            ("사용 가능한 용량이 " ++ cpuPercent ++ " 남았어요")
                        ]
                    ]
                , div [ class "net" ]
                    [ h4 []
                        [ text "NET                "
                        , strong []
                            [ text (netTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span
                            [ attribute "data-status" netColor
                            , attribute "style" ("width:" ++ netPercent)
                            , title ("NET :" ++ netPercent)
                            ]
                            []
                        ]
                    , p []
                        [ text ("사용 가능한 용량이 " ++ netPercent ++ " 남았어요") ]
                    ]
                , div [ class "ram" ]
                    [ h4 []
                        [ text "RAM                "
                        , strong []
                            [ text (ramTotal ++ " Total") ]
                        ]
                    , div [ class "graph" ]
                        [ span [ attribute "data-status" ramColor, attribute "style" ("width: " ++ ramPercent), title ("RAM : " ++ ramPercent) ]
                            []
                        ]
                    , p []
                        [ text ("사용 가능한 용량이 " ++ ramPercent ++ " 남았어요") ]
                    ]
                ]
            , div [ class "transaction_history" ]
                [ h3 []
                    [ text "트랜잭션" ]
                , div [ class "custom dropdown_list area", attribute "role" "list" ]
                    [ button [ attribute "aria-level" "1", attribute "role" "listitem", type_ "button" ]
                        [ text "트랜잭션 타입" ]
                    , div [ class "wrapper" ]
                        [ button [ attribute "role" "listitem", type_ "button" ]
                            [ text "All" ]
                        , button [ attribute "role" "listitem", type_ "button" ]
                            [ text "빌려주기" ]
                        , button [ attribute "role" "listitem", type_ "button" ]
                            [ text "전송하기" ]
                        ]
                    ]
                , node "script"
                    []
                    [ text "(function () {            var target = document.querySelector('div.dropdown_list'),                handler = document.querySelector('div.dropdown_list.area > button[aria-level]');            handler.addEventListener('click',function () {                target.classList.toggle('expand');            });        })();        " ]
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
                                [ text "received" ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            , td []
                                [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                            ]
                        , tr []
                            [ td []
                                [ text "received" ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            , td []
                                [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                            ]
                        , tr []
                            [ td []
                                [ text "received" ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            , td []
                                [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                            ]
                        , tr []
                            [ td []
                                [ text "received" ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            , td []
                                [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                            ]
                        , tr []
                            [ td []
                                [ text "received" ]
                            , td []
                                [ text "8:06:36 AM, Apr 6, 2018" ]
                            , td []
                                [ text "eosyscommuni -& eosyslievink 0.1 EOS" ]
                            ]
                        , tr []
                            [ td []
                                [ text "received" ]
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
                , div [ class "btn_area center" ]
                    [ button [ class "bg_icon add blue_white load button", type_ "button" ]
                        [ text "더 보기" ]
                    ]
                ]
            ]



-- Total Amount = core_liquid_balance + (staked * 0.0001) + (unstaking_net_amount + unstaking_cpu_amount)


getTotalAmount : String -> Int -> String -> String -> String
getTotalAmount core_liquid_balance staked unstaking_net_amount unstaking_cpu_amount =
    (eosStringToFloat (core_liquid_balance)
        + (larimerToEos staked)
        + eosStringToFloat (unstaking_net_amount)
        + eosStringToFloat (unstaking_cpu_amount)
        |> Round.round 4
    )
        ++ " EOS"


getUnstakingAmount : String -> String -> String
getUnstakingAmount unstaking_net_amount unstaking_cpu_amount =
    eosFloatToString (eosStringToFloat unstaking_net_amount + eosStringToFloat unstaking_cpu_amount)



-- getResource ( cpu/net, used, available, max ) -> ( totalString, avaliablePercent )


getResource : String -> Int -> Int -> Int -> ( String, String, String )
getResource resourceFlag used available max =
    let
        totalString =
            case resourceFlag of
                "net" ->
                    -- Bytes
                    if max < 1024 then
                        (toString max) ++ " bytes"
                        -- KB
                    else if (max >= 1024) && (max < (1024 * 1024)) then
                        (Round.round 4 (toFloat max / 1024)) ++ " KB"
                        -- MB
                    else if (max >= 1024 * 1024) && (max < (1024 * 1024 * 1024)) then
                        (Round.round 4 (toFloat max / (1024 * 1024))) ++ " MB"
                        -- GB
                    else if (max >= 1024 * 1024 * 1024) && (max < (1024 * 1024 * 1024 * 1024)) then
                        (Round.round 4 (toFloat max / (1024 * 1024 * 1024))) ++ " GB"
                        -- TB
                    else
                        (Round.round 4 (toFloat max / (1024 * 1024 * 1024 * 1024))) ++ " TB"

                "cpu" ->
                    -- ms
                    if max < 1000 then
                        (toString max) ++ " ms"
                        -- sec
                    else if (max >= 1000) && (max < (1000 * 60)) then
                        (Round.round 4 (toFloat max / 1000)) ++ " sec"
                        -- min
                    else if (max >= 1000 * 60) && (max < (1000 * 60 * 60)) then
                        (Round.round 4 (toFloat max / (1000 * 60))) ++ " min"
                        -- hour
                    else if (max >= 1000 * 60 * 60) && (max < (1000 * 60 * 60 * 24)) then
                        (Round.round 4 (toFloat max / (1000 * 60 * 60))) ++ " min"
                        -- day
                    else
                        (Round.round 4 (toFloat max / (1000 * 60 * 60 * 24))) ++ " day"

                "ram" ->
                    -- Bytes
                    if max < 1024 then
                        (toString max) ++ " bytes"
                        -- KB
                    else if (max >= 1024) && (max < (1024 * 1024)) then
                        (Round.round 4 (toFloat max / 1024)) ++ " KB"
                        -- MB
                    else if (max >= 1024 * 1024) && (max < (1024 * 1024 * 1024)) then
                        (Round.round 4 (toFloat max / (1024 * 1024))) ++ " MB"
                        -- GB
                    else if (max >= 1024 * 1024 * 1024) && (max < (1024 * 1024 * 1024 * 1024)) then
                        (Round.round 4 (toFloat max / (1024 * 1024 * 1024))) ++ " GB"
                        -- TB
                    else
                        (Round.round 4 (toFloat max / (1024 * 1024 * 1024 * 1024))) ++ " TB"

                _ ->
                    ""

        avaliablePercent =
            case max of
                0 ->
                    "0%"

                _ ->
                    ((toFloat (available * 100) / toFloat max) |> Round.round 2) ++ "%"

        color =
            case max of
                0 ->
                    "hell"

                _ ->
                    if (toFloat (available * 100) / toFloat max) < 25 then
                        "hell"
                    else if ((toFloat (available * 100) / toFloat max) >= 25 && (toFloat (available * 100) / toFloat max) < 50) then
                        "bad"
                    else if ((toFloat (available * 100) / toFloat max) >= 50 && (toFloat (available * 100) / toFloat max) < 75) then
                        "good"
                    else
                        "fine"
    in
        ( totalString, avaliablePercent, color )


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
            String.toFloat (replace All (regex " EOS") (\_ -> "") str)
    in
        case result of
            Ok val ->
                val

            Err _ ->
                0
