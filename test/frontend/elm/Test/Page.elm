module Test.Page exposing (..)

import Expect
import Navigation exposing (Location)
import Page exposing (..)
import Page.Search as Search
import Page.Transfer as Transfer
import Page.Voting as Voting
import Test exposing (..)
import View.Notification


location : Location
location =
    { href = ""
    , host = ""
    , hostname = ""
    , protocol = ""
    , origin = ""
    , port_ = ""
    , pathname = "/none"
    , search = ""
    , hash = ""
    , username = ""
    , password = ""
    }


tests : Test
tests =
    describe "Page module"
        [ describe "getPage"
            [ test "IndexRoute" <|
                \() -> Expect.equal IndexPage (getPage { location | pathname = "/" })
            , test "VotingRoute" <|
                \() -> Expect.equal (VotingPage Voting.initModel) (getPage { location | pathname = "/voting" })
            , test "TransferRoute" <|
                \() -> Expect.equal (TransferPage Transfer.initModel) (getPage { location | pathname = "/transfer" })
            , test "SearchRoute" <|
                \() -> Expect.equal (SearchPage Search.initModel) (getPage { location | pathname = "/search" })
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage location)
            ]
        , describe "update"
            [ test "UpdateScatterResponse" <|
                \() ->
                    let
                        model =
                            initModel location

                        expectedModel =
                            { model | notification = View.Notification.Ok { code = 200, message = "\n" } }

                        scatterResponse =
                            { code = 200
                            , type_ = ""
                            , message = ""
                            }
                    in
                        Expect.equal
                            ( expectedModel, Cmd.none )
                            (update (UpdateScatterResponse scatterResponse) model)
            ]
        ]
