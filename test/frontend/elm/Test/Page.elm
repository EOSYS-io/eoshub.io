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
                \() -> Expect.equal IndexPage (getPage ( IndexRoute, flags ))
            , test "VotingRoute" <|
                \() -> Expect.equal (VotingPage (Voting.initModel flags)) (getPage ( VotingRoute, flags ))
            , test "TransferRoute" <|
                \() -> Expect.equal (TransferPage (Transfer.initModel flags)) (getPage ( TransferRoute, flags ))
            , test "SearchRoute" <|
                \() -> Expect.equal (SearchPage (Search.initModel flags)) (getPage ( SearchRoute, flags ))
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage ( NotFoundRoute, flags ))
            ]
        ]
