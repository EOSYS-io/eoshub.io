-- This module provides miscellaneous JSON decoders.


module Data.Json exposing
    ( Producer
    , VoteStat
    , initProducer
    , initVoteStat
    , producerDecoder
    , producersDecoder
    , voteStatDecoder
    )

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


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