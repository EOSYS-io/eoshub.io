-- This module provides miscellaneous JSON decoders.


module Data.Json exposing
    ( CreateEosAccountResponse
    , LocalStorageValue
    , Producer
    , Product
    , RequestPaymentResponse
    , VoteStat
    , createEosAccountResponseDecoder
    , encodeLocalStorageValue
    , initProducer
    , initProduct
    , initVoteStat
    , producerDecoder
    , producersDecoder
    , productDecoder
    , requestPaymentResposeDecoder
    , voteStatDecoder
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode


type alias VoteStat =
    { totalVotedEos : Float
    , totalStakedEos : Float
    , eosysProxyStakedEos : Float
    , eosysProxyStakedAccountCount : Int
    }


initVoteStat : VoteStat
initVoteStat =
    { totalVotedEos = 0.0
    , totalStakedEos = 0.0
    , eosysProxyStakedEos = 0.0
    , eosysProxyStakedAccountCount = 0
    }


voteStatDecoder : Decoder VoteStat
voteStatDecoder =
    Decode.map4 VoteStat
        (Decode.field "total_voted_eos" Decode.float)
        (Decode.field "total_staked_eos" Decode.float)
        (Decode.field "eosys_proxy_staked_eos" Decode.float)
        (Decode.field "eosys_proxy_staked_account_count" Decode.int)


type alias Producer =
    { owner : String
    , totalVotes : Float
    , producerKey : String
    , location : Int
    , url : String
    , logoImageUrl : String
    , lastClaimTime : String
    , unpaidBlocks : Int
    , isActive : Bool
    , rank : Int
    , prevRank : Int
    , createdAt : String
    , updatedAt : String
    , country : String
    }


initProducer : Producer
initProducer =
    { owner = ""
    , totalVotes = 0.0
    , producerKey = ""
    , location = 0
    , url = ""
    , logoImageUrl = ""
    , lastClaimTime = ""
    , unpaidBlocks = 0
    , isActive = True
    , rank = 0
    , prevRank = 0
    , createdAt = ""
    , updatedAt = ""
    , country = ""
    }


producerDecoder : Decoder Producer
producerDecoder =
    decode Producer
        |> required "owner" Decode.string
        |> required "total_votes" Decode.float
        |> required "producer_key" Decode.string
        |> required "location" Decode.int
        |> required "url" Decode.string
        |> required "logo_image_url" (Decode.oneOf [ Decode.string, Decode.null "" ])
        |> required "last_claim_time" Decode.string
        |> required "unpaid_blocks" Decode.int
        |> required "is_active" Decode.bool
        |> required "rank" Decode.int
        |> required "prev_rank" Decode.int
        |> required "created_at" Decode.string
        |> required "updated_at" Decode.string
        |> required "country" Decode.string


producersDecoder : Decoder (List Producer)
producersDecoder =
    Decode.list producerDecoder


type alias RequestPaymentResponse =
    { token : Int
    , onlineUrl : String
    , mobileUrl : String
    , orderNo : String
    }


requestPaymentResposeDecoder : Decoder RequestPaymentResponse
requestPaymentResposeDecoder =
    decode RequestPaymentResponse
        |> required "token" Decode.int
        |> required "online_url" Decode.string
        |> required "mobile_url" Decode.string
        |> required "order_no" Decode.string


type alias Product =
    { id : Int
    , active : Bool
    , name : String
    , price : Int
    , eventActivation : Bool
    , cpu : Float
    , net : Float
    , ram : Int
    }


initProduct : Product
initProduct =
    { id = 0
    , active = False
    , name = ""
    , price = 0
    , eventActivation = False
    , cpu = 0.0
    , net = 0.0
    , ram = 0
    }


productDecoder : Decoder Product
productDecoder =
    decode Product
        |> required "id" Decode.int
        |> required "active" Decode.bool
        |> required "name" Decode.string
        |> required "price" Decode.int
        |> required "event_activation" Decode.bool
        |> required "cpu" Decode.float
        |> required "net" Decode.float
        |> required "ram" Decode.int


type alias CreateEosAccountResponse =
    { eosAccount : String
    , publicKey : String
    }


createEosAccountResponseDecoder : Decoder CreateEosAccountResponse
createEosAccountResponseDecoder =
    decode CreateEosAccountResponse
        |> required "eos_account" Decode.string
        |> required "public_key" Decode.string


type alias LocalStorageValue =
    { lastSkippedAnnouncementId : Int }


encodeLocalStorageValue : LocalStorageValue -> Encode.Value
encodeLocalStorageValue { lastSkippedAnnouncementId } =
    Encode.object
        [ ( "lastSkippedAnnouncementId", Encode.int lastSkippedAnnouncementId ) ]
