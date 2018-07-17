module Test.Page exposing (..)

import Expect
import Page exposing (..)
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Route exposing (Route(..))
import Test exposing (..)


tests : Test
tests =
    let
        flags =
            { node_env = "test" }
    in
    describe "Page module"
        [ describe "getPage"
            [ test "IndexRoute" <|
                \() -> Expect.equal IndexPage (getPage IndexRoute)
            , test "VotingRoute" <|
                \() -> Expect.equal (VotingPage Voting.initModel) (getPage VotingRoute)
            , test "TransferRoute" <|
                \() -> Expect.equal (TransferPage Transfer.initModel) (getPage TransferRoute)
            , test "SearchRoute" <|
                \() -> Expect.equal (SearchPage Search.initModel) (getPage SearchRoute)
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage NotFoundRoute)
            ]
        ]
