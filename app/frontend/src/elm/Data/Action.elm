module Data.Action exposing
    ( Action
    , ActionParameters(..)
    , BuyramParameters
    , BuyrambytesParameters
    , ClaimrewardsParameters
    , DelegatebwParameters
    , NewaccountParameters
    , RegproxyParameters
    , SellramParameters
    , TransferParameters
    , UndelegatebwParameters
    , UpdateauthParameters
    , VoteproducerParameters
    , actionParametersDecoder
    , actionsDecoder
    , buyramDecoder
    , buyrambytesDecoder
    , claimrewardsDecoder
    , delegatebwDecoder
    , encodeActions
    , errorDecoder
    , initBuyramParameters
    , initSellramParameters
    , newaccountDecoder
    , refineAction
    , regproxyDecoder
    , removeDuplicated
    , sellramDecoder
    , transferDecoder
    , undelegatebwDecoder
    , voteproducerDecoder
    )

import Data.Account exposing (intOrStringDecoder)
import Data.Common
    exposing
        ( Authority
        , authorityDecoder
        , encodeAuthority
        )
import Json.Decode as Decode exposing (Decoder, oneOf)
import Json.Decode.Pipeline exposing (decode, hardcoded, required, requiredAt)
import Json.Encode as Encode exposing (encode)
import List.Extra as List exposing (uniqueBy)
import Util.Formatter exposing (formatAsset)



-- the reason why it uses actionTag field separated with actionName is
-- for the tag like 'Received', 'Sent'. These are actually 'Trasfer' actions
-- but These should show different texts


type alias Action =
    { globalSequence : Int
    , blockNum : Int
    , blockTime : String
    , contractAccount : String
    , actionName : String
    , data : Result String ActionParameters
    , trxId : String
    , actionTag : String
    }


type ActionParameters
    = Transfer String TransferParameters
    | Claimrewards ClaimrewardsParameters
    | Sellram SellramParameters
    | Buyram BuyramParameters
    | Buyrambytes BuyrambytesParameters
    | Delegatebw DelegatebwParameters
    | Undelegatebw UndelegatebwParameters
    | Regproxy RegproxyParameters
    | Voteproducer VoteproducerParameters
    | Newaccount NewaccountParameters
    | Updateauth UpdateauthParameters


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
    , bytes : Int
    }


initSellramParameters : SellramParameters
initSellramParameters =
    { account = ""
    , bytes = 0
    }


type alias BuyramParameters =
    { payer : String
    , receiver : String
    , quant : String
    }


initBuyramParameters : BuyramParameters
initBuyramParameters =
    { payer = ""
    , receiver = ""
    , quant = ""
    }


type alias BuyrambytesParameters =
    { payer : String
    , receiver : String
    , bytes : Int
    }


type alias UpdateauthParameters =
    { account : String
    , permission : String
    , parent : String
    , auth : Authority
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
    , owner : Authority
    , active : Authority
    }



-- UPDATE


actionsDecoder : Decoder (List Action)
actionsDecoder =
    Decode.field "actions"
        (Decode.list
            (decode
                Action
                |> requiredAt [ "receipt", "global_sequence" ] intOrStringDecoder
                |> required "block_num" Decode.int
                |> required "block_time" Decode.string
                |> requiredAt [ "act", "account" ] Decode.string
                |> requiredAt [ "act", "name" ] Decode.string
                |> requiredAt [ "act", "data" ] actionParametersDecoder
                |> required "trx_id" Decode.string
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
    -- The contract account parameter of Transfer constructor is useless in this case cause
    -- the paramaeter can be determined in former decoding phase.
    Decode.map (Transfer "") <|
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
            |> required "bytes" Decode.int
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
            |> required "owner" authorityDecoder
            |> required "active" authorityDecoder
        )


refineAction : String -> Action -> Action
refineAction accountName ({ contractAccount, actionName, data } as model) =
    case data of
        -- controlled actions
        Ok actionParameters ->
            case ( contractAccount, actionName ) of
                ( "eosio.token", "transfer" ) ->
                    case actionParameters of
                        Transfer _ params ->
                            let
                                actionTag =
                                    if accountName == params.to then
                                        "Received"

                                    else if accountName == params.from then
                                        "Sent"

                                    else
                                        "exceptional case"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "sellram" ) ->
                    case actionParameters of
                        Sellram _ ->
                            let
                                actionTag =
                                    "Sell Ram"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "buyram" ) ->
                    case actionParameters of
                        Buyram _ ->
                            let
                                actionTag =
                                    "Buy Ram"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "buyrambytes" ) ->
                    case actionParameters of
                        Buyrambytes _ ->
                            let
                                actionTag =
                                    "Buy Ram Bytes"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "delegatebw" ) ->
                    case actionParameters of
                        Delegatebw _ ->
                            let
                                actionTag =
                                    "Delegate"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "undelegatebw" ) ->
                    case actionParameters of
                        Undelegatebw _ ->
                            let
                                actionTag =
                                    "Undelegate"
                            in
                            { model | actionTag = actionTag }

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
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "voteproducer" ) ->
                    case actionParameters of
                        Voteproducer params ->
                            let
                                -- isproxy - true if proxy wishes to vote on behalf of others, false otherwise
                                actionTag =
                                    if String.length params.proxy == 0 then
                                        "Vote"

                                    else
                                        "Proxy vote"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                ( "eosio", "newaccount" ) ->
                    case actionParameters of
                        Newaccount _ ->
                            let
                                actionTag =
                                    "New Account"
                            in
                            { model | actionTag = actionTag }

                        _ ->
                            model

                _ ->
                    { model | actionTag = contractAccount ++ ":" ++ actionName }

        -- undefined actions in eoshub
        Err _ ->
            { model | actionTag = contractAccount ++ ":" ++ actionName }


errorDecoder : Decoder String
errorDecoder =
    Decode.value
        |> Decode.map (encode 0)



-- encoder part


encodeActions : String -> List ActionParameters -> Encode.Value
encodeActions actionName actions =
    Encode.object
        [ ( "actionName", Encode.string actionName )
        , ( "actions", Encode.list (List.map encodeAction actions) )
        ]


encodeAction : ActionParameters -> Encode.Value
encodeAction action =
    case action of
        Transfer contractAccount message ->
            transferParametersToValue contractAccount message

        Delegatebw message ->
            delegatebwParametersToValue message

        Undelegatebw message ->
            undelegatebwParametersToValue message

        Buyram message ->
            buyramParametersToValue message

        Sellram message ->
            sellramParametersToValue message

        Voteproducer message ->
            voteproducersParametersToValue message

        Updateauth message ->
            updateauthParametersToValue message

        Newaccount message ->
            newaccountParametersToValue message

        Buyrambytes message ->
            buyrambytesParametersToValue message

        _ ->
            Encode.null


transferParametersToValue : String -> TransferParameters -> Encode.Value
transferParametersToValue contractAccount { from, to, quantity, memo } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string contractAccount )
        , ( "action", Encode.string "transfer" )
        , ( "payload"
          , Encode.object
                [ ( "from", Encode.string from )
                , ( "to", Encode.string to )
                , ( "quantity", Encode.string quantity )
                , ( "memo", Encode.string memo )
                ]
          )
        ]


delegatebwParametersToValue : DelegatebwParameters -> Encode.Value
delegatebwParametersToValue { from, receiver, stakeNetQuantity, stakeCpuQuantity, transfer } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "delegatebw" )
        , ( "payload"
          , Encode.object
                [ ( "from", Encode.string from )
                , ( "receiver", Encode.string receiver )
                , ( "stake_net_quantity", Encode.string (stakeNetQuantity |> formatAsset) )
                , ( "stake_cpu_quantity", Encode.string (stakeCpuQuantity |> formatAsset) )
                , ( "transfer", Encode.int transfer )
                ]
          )
        ]


undelegatebwParametersToValue : UndelegatebwParameters -> Encode.Value
undelegatebwParametersToValue { from, receiver, unstakeNetQuantity, unstakeCpuQuantity } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "undelegatebw" )
        , ( "payload"
          , Encode.object
                [ ( "from", Encode.string from )
                , ( "receiver", Encode.string receiver )
                , ( "unstake_net_quantity", Encode.string (unstakeNetQuantity |> formatAsset) )
                , ( "unstake_cpu_quantity", Encode.string (unstakeCpuQuantity |> formatAsset) )
                ]
          )
        ]


buyramParametersToValue : BuyramParameters -> Encode.Value
buyramParametersToValue { payer, receiver, quant } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "buyram" )
        , ( "payload"
          , Encode.object
                [ ( "payer", Encode.string payer )
                , ( "receiver", Encode.string receiver )
                , ( "quant", Encode.string (quant |> formatAsset) )
                ]
          )
        ]


buyrambytesParametersToValue : BuyrambytesParameters -> Encode.Value
buyrambytesParametersToValue { payer, receiver, bytes } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "buyrambytes" )
        , ( "payload"
          , Encode.object
                [ ( "payer", Encode.string payer )
                , ( "receiver", Encode.string receiver )
                , ( "bytes", Encode.int bytes )
                ]
          )
        ]


sellramParametersToValue : SellramParameters -> Encode.Value
sellramParametersToValue { account, bytes } =
    -- Introduce form validation.
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "sellram" )
        , ( "payload"
          , Encode.object
                [ ( "account", Encode.string account )
                , ( "bytes", Encode.int bytes )
                ]
          )
        ]


voteproducersParametersToValue : VoteproducerParameters -> Encode.Value
voteproducersParametersToValue { voter, producers, proxy } =
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "voteproducer" )
        , ( "payload"
          , Encode.object
                [ ( "voter", Encode.string voter )
                , ( "proxy", Encode.string proxy )
                , ( "producers", Encode.list (List.map Encode.string producers) )
                ]
          )
        ]


updateauthParametersToValue : UpdateauthParameters -> Encode.Value
updateauthParametersToValue { account, permission, parent, auth } =
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "updateauth" )
        , ( "payload"
          , Encode.object
                [ ( "account", Encode.string account )
                , ( "permission", Encode.string permission )
                , ( "parent", Encode.string parent )
                , ( "auth", encodeAuthority auth )
                ]
          )
        ]


newaccountParametersToValue : NewaccountParameters -> Encode.Value
newaccountParametersToValue { creator, name, owner, active } =
    Encode.object
        [ ( "account", Encode.string "eosio" )
        , ( "action", Encode.string "newaccount" )
        , ( "payload"
          , Encode.object
                [ ( "creator", Encode.string creator )
                , ( "name", Encode.string name )
                , ( "owner", encodeAuthority owner )
                , ( "active", encodeAuthority active )
                ]
          )
        ]



-- Utility


removeDuplicated : List Action -> List Action
removeDuplicated actionList =
    let
        getActionIdentifier action =
            toString action.trxId
                ++ toString action.contractAccount
                ++ toString action.actionName
                ++ toString action.data
    in
    uniqueBy getActionIdentifier actionList
