module Util.Urls exposing (..)

import Util.Flags exposing (Flags)


eoshub_host : Flags -> String
eoshub_host flags =
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


usersApiUrl : Flags -> String
usersApiUrl flags =
    eoshub_host flags ++ "/users"


createEosAccountUrl : ( Flags, String ) -> String
createEosAccountUrl ( flags, confirmToken ) =
    eoshub_host flags ++ "/users/" ++ confirmToken ++ "/create_eos_account"
