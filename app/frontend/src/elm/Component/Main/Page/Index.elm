module Component.Main.Page.Index exposing (Message(ChangeUrl, OpenUnderConstruction), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)


-- MESSAGE --


type Message
    = ChangeUrl String
    | OpenUnderConstruction



-- VIEW --


view : Language -> Html Message
view language =
    section [ class "action view panel" ]
        [ a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (ChangeUrl "/transfer")
            ]
            [ div [ class "card transfer" ]
                [ h3 [] [ text (translate language Transfer) ]
                , p [] [ text (translate language TransferDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (OpenUnderConstruction)
            ]
            [ div [ class "card ram_market" ]
                [ h3 [] [ text (translate language RamMarket) ]
                , p [] [ text (translate language RamMarketDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (OpenUnderConstruction)
            ]
            [ div [ class "card application" ]
                [ h3 [] [ text (translate language Application) ]
                , p [] [ text (translate language ApplicationDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (OpenUnderConstruction)
            ]
            [ div [ class "card vote" ]
                [ h3 [] [ text (translate language Vote) ]
                , p [] [ text (translate language VoteDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (OpenUnderConstruction)
            ]
            [ div [ class "card proxy_vote" ]
                [ h3 [] [ text (translate language ProxyVote) ]
                , p [] [ text (translate language ProxyVoteDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (OpenUnderConstruction)
            ]
            [ div [ class "card faq" ]
                [ h3 [] [ text (translate language Faq) ]
                , p [] [ text (translate language FaqDesc) ]
                ]
            ]
        ]
