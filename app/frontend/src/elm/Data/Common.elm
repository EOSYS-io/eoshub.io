module Data.Common exposing
    ( AppState
    , Authority
    , KeyWeight
    , PermissionLevel
    , PermissionLevelWeight
    , Setting
    , WaitWeight
    , appStateDecoder
    , authorityDecoder
    , encodeAuthority
    , initAppState
    , initSetting
    )

import Data.Announcement exposing (Announcement, announcementDecoder, initAnnouncement)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required, requiredAt)
import Json.Encode as Encode
import Util.Formatter exposing (floatToAsset)


type alias AppState =
    { announcement : Announcement
    , setting : Setting
    , eventActivation : Bool
    }


initAppState : AppState
initAppState =
    { eventActivation = False
    , announcement = initAnnouncement
    , setting = initSetting
    }


type alias Setting =
    { eosysProxyAccount : String
    , historyApiLimit : Int
    , minimumRequiredCpu : String
    , minimumRequiredNet : String
    , newAccountCpu : String
    , newAccountNet : String
    , newAccountRam : Int
    }


initSetting : Setting
initSetting =
    { eosysProxyAccount = "bpgovernance"
    , historyApiLimit = 100
    , minimumRequiredCpu = "0.8 EOS"
    , minimumRequiredNet = "0.2 EOS"
    , newAccountCpu = "0.1"
    , newAccountNet = "0.1"
    , newAccountRam = 3072
    }



-- NOTE(heejae): See details of eosio native data types on
-- https://github.com/EOSIO/eos/blob/905e7c85714aee4286fa180ce946f15ceb4ce73c/libraries/chain/eosio_contract_abi.cpp


type alias PermissionLevel =
    { actor : String
    , permission : String
    }


type alias PermissionLevelWeight =
    { permission : PermissionLevel
    , weight : Int
    }


type alias WaitWeight =
    { waitSec : Int
    , weight : Int
    }


type alias KeyWeight =
    { key : String
    , weight : Int
    }


type alias Authority =
    { threshold : Int
    , keys : List KeyWeight
    , accounts : List PermissionLevelWeight
    , waits : List WaitWeight
    }



-- Decoder


appStateDecoder : Decoder AppState
appStateDecoder =
    decode AppState
        |> requiredAt [ "data", "announcement" ] announcementDecoder
        |> requiredAt [ "data", "setting" ] settingDecoder
        |> requiredAt [ "data", "event_activation" ] Decode.bool


settingDecoder : Decoder Setting
settingDecoder =
    decode Setting
        |> required "eosys_proxy_account" Decode.string
        |> required "history_api_limit" Decode.int
        |> required "minimum_required_cpu" minimumRequiredResourceDecoder
        |> required "minimum_required_net" minimumRequiredResourceDecoder
        |> required "new_account_cpu" newAccountResourceDecoder
        |> required "new_account_net" newAccountResourceDecoder
        |> required "new_account_ram" Decode.int


minimumRequiredResourceDecoder : Decoder String
minimumRequiredResourceDecoder =
    Decode.map
        (\value ->
            floatToAsset 1 "EOS" value
        )
        Decode.float


newAccountResourceDecoder : Decoder String
newAccountResourceDecoder =
    Decode.map (\value -> toString value) Decode.float


authorityDecoder : Decoder Authority
authorityDecoder =
    decode Authority
        |> required "threshold" Decode.int
        |> required "keys"
            (Decode.list
                (decode KeyWeight
                    |> required "key" Decode.string
                    |> required "weight" Decode.int
                )
            )
        |> required "accounts"
            (Decode.list
                (decode PermissionLevelWeight
                    |> required "permission"
                        (decode PermissionLevel
                            |> required "actor" Decode.string
                            |> required "permission" Decode.string
                        )
                    |> required "weight" Decode.int
                )
            )
        |> required "waits"
            (Decode.list
                (decode WaitWeight
                    |> required "wait_sec" Decode.int
                    |> required "weight" Decode.int
                )
            )



-- Encoder


encodeAuthority : Authority -> Encode.Value
encodeAuthority auth =
    Encode.object
        [ ( "accounts"
          , Encode.list
                (List.map
                    (\permLevel ->
                        Encode.object
                            [ ( "permission"
                              , Encode.object
                                    [ ( "permission"
                                      , Encode.string permLevel.permission.permission
                                      )
                                    , ( "actor"
                                      , Encode.string permLevel.permission.actor
                                      )
                                    ]
                              )
                            , ( "weight", Encode.int permLevel.weight )
                            ]
                    )
                    auth.accounts
                )
          )
        , ( "threshold", Encode.int auth.threshold )
        , ( "waits"
          , Encode.list
                (List.map
                    (\{ waitSec, weight } ->
                        Encode.object
                            [ ( "wait_sec", Encode.int waitSec )
                            , ( "weight", Encode.int weight )
                            ]
                    )
                    auth.waits
                )
          )
        , ( "keys"
          , Encode.list
                (List.map
                    (\{ key, weight } ->
                        Encode.object
                            [ ( "key", Encode.string key )
                            , ( "weight", Encode.int weight )
                            ]
                    )
                    auth.keys
                )
          )
        ]
