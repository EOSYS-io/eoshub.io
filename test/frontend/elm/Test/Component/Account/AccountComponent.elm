module Test.Component.Account.AccountComponent exposing (location, tests)

import Component.Account.AccountComponent exposing (..)
import Component.Account.Page.Created as Created
import Component.Account.Page.EventCreation as EventCreation
import Expect
import Navigation exposing (Location)
import Route
import Test exposing (..)
import Translation


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
    let
        flags =
            { node_env = "test" }

        language =
            Translation.Korean
    in
    describe "Page module"
        [ describe "getPage"
            [ test "CreatedRoute" <|
                \() ->
                    let
                        eosAccount =
                            Just "testtesttest"

                        publicKey =
                            Just "lasdihgalsghasldgihasggasdgasdgagsafgas"
                    in
                    Expect.equal (CreatedPage <| Created.initModel eosAccount publicKey) (getPage <| Route.CreatedRoute eosAccount publicKey)
            , test "EventCreationRoute" <|
                \() ->
                    Expect.equal (EventCreationPage EventCreation.initModel) (getPage <| Route.EventCreationRoute <| Just "ko")
            , test "NotFoundRoute" <|
                \() -> Expect.equal NotFoundPage (getPage Route.NotFoundRoute)
            ]
        , describe "initCmd"
            [ test "EventCreationRoute" <|
                \() ->
                    let
                        eventCreationModel =
                            EventCreation.initModel

                        ( newEventCreationModel, subCmd ) =
                            EventCreation.update EventCreation.GenerateKeys eventCreationModel flags language

                        expectedPage =
                            EventCreationPage newEventCreationModel

                        expectedCmd =
                            Cmd.map EventCreationMessage subCmd

                        model =
                            { page = expectedPage
                            , language = Translation.Korean
                            , flags = { node_env = "test" }
                            }
                    in
                    Expect.equal expectedCmd (initCmd model)
            ]
        ]
