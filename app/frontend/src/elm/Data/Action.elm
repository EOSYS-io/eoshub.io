module Data.Action exposing (..)

import Json.Decode as Decode exposing (Decoder, oneOf, decodeString)
import Json.Encode as Encode exposing (encode)
import Json.Decode.Pipeline exposing (decode, required, optional, requiredAt, hardcoded)
import Util.Formatter exposing (formatEosQuantity)


-- the reason why it uses actionTag field separated with actionName is
-- for the tag like 'Received', 'Sent'. These are actually 'Trasfer' actions
-- but These should show different texts


type alias Action =
    { accountActionSeq : Int
    , blockNum : Int
    , blockTime : String
    , contractAccount : String
    , actionName : String
    , data : Result String ActionParameters
    , actionTag : String
    , info : String
    }


type ActionParameters
    = Transfer TransferParameters
    | Claimrewards ClaimrewardsParameters
    | Sellram SellramParameters
    | Buyram BuyramParameters
    | Buyrambytes BuyrambytesParameters
    | Delegatebw DelegatebwParameters
    | Undelegatebw UndelegatebwParameters
    | Regproxy RegproxyParameters
    | Voteproducer VoteproducerParameters
    | Newaccount NewaccountParameters


type alias TransferParameters =
    { from : String
    , to : String
    , quantity : String
    , memo : String
    }


type alias ClaimrewardsParameters =
    { owner : String
    }


type alias SellramParameters =
    { account : String
    , bytes : String
    }


type alias BuyramParameters =
    { payer : String
    , receiver : String
    , quant : String
    }


type alias BuyrambytesParameters =
    { payer : String
    , receiver : String
    , bytes : Int
    }



-- transfer type is bool but eosio pass the value as 0 or 1. so it should be Int in Elm


type alias DelegatebwParameters =
    { from : String
    , receiver : String
    , stakeNetQuantity : String
    , stakeCpuQuantity : String
    , transfer : Int
    }


type alias UndelegatebwParameters =
    { from : String
    , receiver : String
    , unstakeNetQuantity : String
    , unstakeCpuQuantity : String
    }



-- isproxy type is bool but eosio pass the value as 0 or 1. so it should be Int in Elm


type alias RegproxyParameters =
    { proxy : String
    , isproxy : Int
    }


type alias VoteproducerParameters =
    { voter : String
    , proxy : String
    , producers : List String
    }


type alias NewaccountParameters =
    { creator : String
    , name : String
    }


actionsDecoder : Decoder (List Action)
actionsDecoder =
    Decode.field "actions"
        (Decode.list
            (decode
                Action
                |> required "account_action_seq" Decode.int
                |> required "block_num" Decode.int
                |> required "block_time" Decode.string
                |> requiredAt [ "action_trace", "act", "account" ] Decode.string
                |> requiredAt [ "action_trace", "act", "name" ] Decode.string
                |> requiredAt [ "action_trace", "act", "data" ] actionParametersDecoder
                |> hardcoded ""
                |> hardcoded ""
            )
        )


actionParametersDecoder : Decoder (Result String ActionParameters)
actionParametersDecoder =
    oneOf
        [ Decode.map Ok transferDecoder
        , Decode.map Ok sellramDecoder
        , Decode.map Ok buyramDecoder
        , Decode.map Ok buyrambytesDecoder
        , Decode.map Ok claimrewardsDecoder
        , Decode.map Ok delegatebwDecoder
        , Decode.map Ok undelegatebwDecoder
        , Decode.map Ok regproxyDecoder
        , Decode.map Ok voteproducerDecoder
        , Decode.map Ok newaccountDecoder
        , Decode.map Err errorDecoder
        ]


transferDecoder : Decoder ActionParameters
transferDecoder =
    Decode.map Transfer <|
        (decode
            TransferParameters
            |> required "from" Decode.string
            |> required "to" Decode.string
            |> required "quantity" Decode.string
            |> required "memo" Decode.string
        )


claimrewardsDecoder : Decoder ActionParameters
claimrewardsDecoder =
    Decode.map Claimrewards <|
        (decode ClaimrewardsParameters
            |> required "owner" Decode.string
        )


sellramDecoder : Decoder ActionParameters
sellramDecoder =
    Decode.map Sellram <|
        (decode SellramParameters
            |> required "account" Decode.string
            |> required "bytes" Decode.string
        )


buyramDecoder : Decoder ActionParameters
buyramDecoder =
    Decode.map Buyram <|
        (decode BuyramParameters
            |> required "payer" Decode.string
            |> required "receiver" Decode.string
            |> required "quant" Decode.string
        )


buyrambytesDecoder : Decoder ActionParameters
buyrambytesDecoder =
    Decode.map Buyrambytes <|
        (decode BuyrambytesParameters
            |> required "payer" Decode.string
            |> required "receiver" Decode.string
            |> required "bytes" Decode.int
        )


delegatebwDecoder : Decoder ActionParameters
delegatebwDecoder =
    Decode.map Delegatebw <|
        (decode DelegatebwParameters
            |> required "from" Decode.string
            |> required "receiver" Decode.string
            |> required "stake_net_quantity" Decode.string
            |> required "stake_cpu_quantity" Decode.string
            |> required "transfer" Decode.int
        )


undelegatebwDecoder : Decoder ActionParameters
undelegatebwDecoder =
    Decode.map Undelegatebw <|
        (decode UndelegatebwParameters
            |> required "from" Decode.string
            |> required "receiver" Decode.string
            |> required "unstake_net_quantity" Decode.string
            |> required "unstake_cpu_quantity" Decode.string
        )


regproxyDecoder : Decoder ActionParameters
regproxyDecoder =
    Decode.map Regproxy <|
        (decode RegproxyParameters
            |> required "proxy" Decode.string
            |> required "isproxy" Decode.int
        )


voteproducerDecoder : Decoder ActionParameters
voteproducerDecoder =
    Decode.map Voteproducer <|
        (decode VoteproducerParameters
            |> required "voter" Decode.string
            |> required "proxy" Decode.string
            |> required "producers" (Decode.list Decode.string)
        )


newaccountDecoder : Decoder ActionParameters
newaccountDecoder =
    Decode.map Newaccount <|
        (decode NewaccountParameters
            |> required "creator" Decode.string
            |> required "name" Decode.string
        )


refineAction : String -> Action -> Action
refineAction accountName ({ contractAccount, actionName, data } as model) =
    case data of
        -- controlled actions
        Ok actionParameters ->
            case ( contractAccount, actionName ) of
                ( "eosio.token", "transfer" ) ->
                    case actionParameters of
                        Transfer params ->
                            let
                                actionTag =
                                    if accountName == params.to then
                                        "Received"
                                    else if accountName == params.from then
                                        "Sent"
                                    else
                                        "exceptional case"

                                info =
                                    params.from
                                        ++ " -> "
                                        ++ params.to
                                        ++ " "
                                        ++ params.quantity
                                        ++ " (Memo: "
                                        ++ params.memo
                                        ++ ")"
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "sellram" ) ->
                    case actionParameters of
                        Sellram params ->
                            let
                                actionTag =
                                    "Sell Ram"

                                info =
                                    params.account ++ " sold " ++ params.bytes ++ " bytes RAM"
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "buyram" ) ->
                    case actionParameters of
                        Buyram params ->
                            let
                                actionTag =
                                    "Buy Ram"

                                info =
                                    params.payer ++ " bought " ++ params.quant ++ " RAM for " ++ params.receiver
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "buyrambytes" ) ->
                    case actionParameters of
                        Buyrambytes params ->
                            let
                                actionTag =
                                    "Buy Ram Bytes"

                                info =
                                    params.payer
                                        ++ " bought "
                                        ++ toString params.bytes
                                        ++ " bytes RAM for "
                                        ++ params.receiver
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "delegatebw" ) ->
                    case actionParameters of
                        Delegatebw params ->
                            let
                                actionTag =
                                    "Delegate"

                                info =
                                    params.from
                                        ++ " delegated to the account "
                                        ++ params.receiver
                                        ++ " "
                                        ++ params.stakeNetQuantity
                                        ++ " for NET, and "
                                        ++ params.stakeCpuQuantity
                                        ++ " for CPU "
                                        ++ (if params.transfer == 1 then
                                                "(transfer)"
                                            else
                                                ""
                                           )
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "undelegatebw" ) ->
                    case actionParameters of
                        Undelegatebw params ->
                            let
                                actionTag =
                                    "Undelegate"

                                info =
                                    params.receiver
                                        ++ " undelegated from the account "
                                        ++ params.from
                                        ++ " "
                                        ++ params.unstakeNetQuantity
                                        ++ " for NET, and "
                                        ++ params.unstakeCpuQuantity
                                        ++ " for CPU"
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "regproxy" ) ->
                    case actionParameters of
                        Regproxy params ->
                            let
                                -- isproxy - true if proxy wishes to vote on behalf of others, false otherwise
                                actionTag =
                                    if params.isproxy == 1 then
                                        "Register Proxy"
                                    else
                                        "Unregister Proxy"

                                info =
                                    if params.isproxy == 1 then
                                        params.proxy ++ " registered as voting proxy"
                                    else
                                        params.proxy
                                            ++ " unregistered as voting proxy"
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "voteproducer" ) ->
                    case actionParameters of
                        Voteproducer params ->
                            let
                                -- isproxy - true if proxy wishes to vote on behalf of others, false otherwise
                                actionTag =
                                    if (String.length params.proxy) == 0 then
                                        "Vote"
                                    else
                                        "Vote though proxy"

                                info =
                                    -- is not proxy case
                                    if (String.length params.proxy) == 0 then
                                        params.voter ++ " voted for block producers " ++ toString params.producers
                                    else
                                        params.voter ++ " voted through " ++ params.proxy
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                ( "eosio", "newaccount" ) ->
                    case actionParameters of
                        Newaccount params ->
                            let
                                actionTag =
                                    "New Account"

                                info =
                                    "New account " ++ params.name ++ " was created by " ++ params.creator
                            in
                                { model | actionTag = actionTag, info = info }

                        _ ->
                            model

                _ ->
                    { model | actionTag = contractAccount ++ ":" ++ actionName, info = toString actionParameters }

        -- undefined actions in eoshub
        Err str ->
            { model | actionTag = contractAccount ++ ":" ++ actionName, info = str }



-- for the not defined cases


errorDecoder : Decoder String
errorDecoder =
    Decode.value
        |> Decode.map (encode 0)



-- encoder part


encodeAction : ActionParameters -> Encode.Value
encodeAction action =
    case action of
        Transfer message ->
            transferParametersToValue message

        _ ->
            Encode.null


transferParametersToValue : TransferParameters -> Encode.Value
transferParametersToValue { from, to, quantity, memo } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio.token" )
        , ( "action", Encode.string "transfer" )
        , ( "payload"
          , Encode.object
                [ ( "from", Encode.string from )
                , ( "to", Encode.string to )
                , ( "quantity", Encode.string ((quantity |> formatEosQuantity) ++ " EOS") )
                , ( "memo", Encode.string memo )
                ]
          )
        ]
