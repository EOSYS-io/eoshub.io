module Route exposing (Route(..), route, parseLocation)

import Navigation exposing (Location)
import UrlParser exposing (Parser, parsePath, oneOf, map, top, s)


type Route
    = IndexRoute
    | SearchRoute
    | VotingRoute
    | TransferRoute
    | NotFoundRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ map IndexRoute top
        , map SearchRoute (s "search")
        , map VotingRoute (s "voting")
        , map TransferRoute (s "transfer")
        ]


parseLocation : Location -> Route
parseLocation location =
    case parsePath route location of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
