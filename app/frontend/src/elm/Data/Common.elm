module Data.Common exposing
    ( ApplicationState
    , Authority
    , KeyWeight
    , PermissionLevel
    , PermissionLevelWeight
    , WaitWeight
    , authorityDecoder
    , encodeAuthority
    , initApplicationState
    )

import Data.Announcement exposing (Announcement, initAnnouncement)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias ApplicationState =
    { announcement : Announcement
    , setting : Setting
    , eventActivation : Bool
    }


initApplicationState : ApplicationState
initApplicationState =
    { eventActivation = False
    , announcement = initAnnouncement
    , setting = initSetting
    }


type alias Setting =
    { id : Int
    , eosysProxyAccount : String
    , historyApiLimit : Int
    , minimumRequiredCpu : String
    , minimumRequiredNet : String
    , newAccountCpu : String
    , newAccountNet : String
    , newAccountRam : Int
    }


initSetting : Setting
initSetting =
    { id = 0
    , eosysProxyAccount = "bpgovernance"
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
