module Route exposing (..)

import Navigation exposing (Location)
import UrlParser exposing (..)


type Route
    = IndexRoute
    | SearchRoute
    | VotingRoute
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map IndexRoute top
        , map SearchRoute (s "search")
        , map VotingRoute (s "voting")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parsePath route location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
