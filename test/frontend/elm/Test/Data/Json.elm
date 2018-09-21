module Test.Data.Json exposing (tests)

import Data.Json exposing (producerDecoder, producersDecoder, voteStatDecoder)
import Expect
import Json.Decode as JD
import Test exposing (..)


tests : Test
tests =
    let
        producersJson =
            "[{\"owner\":\"eosyskoreabp\",\"total_votes\":3.02033275895348e+17,\"producer_key\":\"EOS7TjKVBkBcSmjsXF4jJfZ1QU9RqVHuBkkcHNJoEcHGR79CoLf2f\",\"location\":0,\"url\":\"https://eosys.io\",\"logo_image_url\":\"https://eosys.io/logo_eosys.svg\",\"last_claim_time\":\"1537413321500000\",\"unpaid_blocks\":0,\"is_active\":true,\"rank\":22,\"prev_rank\":22,\"created_at\":\"2018-09-19T16:43:44.797+09:00\",\"updated_at\":\"2018-09-20T18:00:02.866+09:00\",\"country\":\"KR\"},{\"owner\":\"zbeosbp11111\",\"total_votes\":4.341350220538e+17,\"producer_key\":\"EOS7rhgVPWWyfMqjSbNdndtCK8Gkza3xnDbUupsPLMZ6gjfQ4nX81\",\"location\":156,\"url\":\"https://www.zbeos.com\",\"logo_image_url\":\"https://www.zbeos.com/img/zbeoslogo.svg\",\"last_claim_time\":\"1537347665000000\",\"unpaid_blocks\":8220,\"is_active\":true,\"rank\":2,\"prev_rank\":2,\"created_at\":\"2018-09-19T16:43:21.683+09:00\",\"updated_at\":\"2018-09-20T18:00:02.802+09:00\",\"country\":\"CN\"}]"

        producerJson =
            "{\"owner\":\"eosyskoreabp\",\"total_votes\":3.02033275895348e+17,\"producer_key\":\"EOS7TjKVBkBcSmjsXF4jJfZ1QU9RqVHuBkkcHNJoEcHGR79CoLf2f\",\"location\":0,\"url\":\"https://eosys.io\",\"logo_image_url\":\"https://eosys.io/logo_eosys.svg\",\"last_claim_time\":\"1537413321500000\",\"unpaid_blocks\":0,\"is_active\":true,\"rank\":22,\"prev_rank\":22,\"created_at\":\"2018-09-19T16:43:44.797+09:00\",\"updated_at\":\"2018-09-20T18:00:02.866+09:00\",\"country\":\"KR\"}"

        voteStatJson =
            "{\"id\":673,\"total_voted_eos\":257988127.4387,\"total_staked_eos\":550238222.6297,\"eosys_proxy_staked_eos\":1023219.9134,\"eosys_proxy_staked_account_count\":12,\"created_at\":\"2018-09-20T18:00:12.173+09:00\",\"updated_at\":\"2018-09-20T18:00:12.173+09:00\"}"

        expectedProducers =
            [ expectedProducer
            , { country = "CN"
              , createdAt = "2018-09-19T16:43:21.683+09:00"
              , isActive = True
              , lastClaimTime = "1537347665000000"
              , location = 156
              , logoImageUrl = "https://www.zbeos.com/img/zbeoslogo.svg"
              , owner = "zbeosbp11111"
              , prevRank = 2
              , producerKey = "EOS7rhgVPWWyfMqjSbNdndtCK8Gkza3xnDbUupsPLMZ6gjfQ4nX81"
              , rank = 2
              , totalVotes = 434135022053800000
              , unpaidBlocks = 8220
              , updatedAt = "2018-09-20T18:00:02.802+09:00"
              , url = "https://www.zbeos.com"
              }
            ]

        expectedProducer =
            { country = "KR"
            , createdAt = "2018-09-19T16:43:44.797+09:00"
            , isActive = True
            , lastClaimTime = "1537413321500000"
            , location = 0
            , logoImageUrl = "https://eosys.io/logo_eosys.svg"
            , owner = "eosyskoreabp"
            , prevRank = 22
            , producerKey = "EOS7TjKVBkBcSmjsXF4jJfZ1QU9RqVHuBkkcHNJoEcHGR79CoLf2f"
            , rank = 22
            , totalVotes = 302033275895348000
            , unpaidBlocks = 0
            , updatedAt = "2018-09-20T18:00:02.866+09:00"
            , url = "https://eosys.io"
            }

        expectedVoteStat =
            { eosysProxyStakedAccountCount = 12
            , eosysProxyStakedEos = 1023219.9134
            , totalStakedEos = 550238222.6297
            , totalVotedEos = 257988127.4387
            }
    in
    describe "decoders"
        [ describe "producersDecoder"
            [ test "producers" <|
                \() -> Expect.equal (Ok expectedProducers) (JD.decodeString producersDecoder producersJson)
            ]
        , describe "producerDecoder"
            [ test "producer" <|
                \() -> Expect.equal (Ok expectedProducer) (JD.decodeString producerDecoder producerJson)
            ]
        , describe "voteStatDecoder"
            [ test "voteStat" <|
                \() -> Expect.equal (Ok expectedVoteStat) (JD.decodeString voteStatDecoder voteStatJson)
            ]
        ]
