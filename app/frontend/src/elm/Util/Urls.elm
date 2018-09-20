module Util.Urls exposing
    ( createEosAccountUrl
    , getProducersUrl
    , getRecentVoteStatUrl
    , mainnetRpcUrl
    , usersApiUrl
    )

import Util.Flags exposing (Flags)


eoshubHost : Flags -> String
eoshubHost flags =
    if flags.node_env == "development" then
        "http://localhost:3000"

    else if flags.node_env == "test" then
        "http://localhost:3000"

    else if flags.node_env == "alpha" then
        "http://ecs-first-run-alb-1125793223.ap-northeast-2.elb.amazonaws.com"

    else if flags.node_env == "production" then
        ""

    else
        "http://localhost:3000"


usersApiUrl : Flags -> String -> String
usersApiUrl flags locale =
    eoshubHost flags ++ "/users?locale=" ++ locale


createEosAccountUrl : Flags -> String -> String -> String
createEosAccountUrl flags confirmToken locale =
    eoshubHost flags ++ "/users/" ++ confirmToken ++ "/create_eos_account?locale=" ++ locale


getProducersUrl : Flags -> String
getProducersUrl flags =
    eoshubHost flags ++ "/producers/"


getRecentVoteStatUrl : Flags -> String
getRecentVoteStatUrl flags =
    eoshubHost flags ++ "/vote_stats/recent_stat"


mainnetRpcUrl : String
mainnetRpcUrl =
    -- TODO(boseok): Consider to find fastest api node that we can use.
    -- "http://rpc1.eosys.io:8888"
    -- "https://api1.eosasia.one"
    "https://eos.greymass.com"



--"https://api.eosnewyork.io"
