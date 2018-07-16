module Page.Index exposing (view)

import ExternalMessage
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, translate)


-- VIEW --


view : Language -> Html ExternalMessage.Message
view language =
    section [ class "action view panel" ]
        [ a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (ExternalMessage.ChangeUrl "/transfer")
            ]
            [ div [ class "card transfer" ]
                [ h3 [] [ text (translate language Transfer) ]
                , p [] [ text (translate language TransferDesc) ]
                ]
            ]
        , a [ style [ ( "cursor", "pointer" ) ] ]
            [ div [ class "card ram_market" ]
                [ h3 [] [ text (translate language RamMarket) ]
                , p [] [ text (translate language RamMarketDesc) ]
                ]
            ]
        , a [ style [ ( "cursor", "pointer" ) ] ]
            [ div [ class "card application" ]
                [ h3 [] [ text (translate language Application) ]
                , p [] [ text (translate language ApplicationDesc) ]
                ]
            ]
        , a
            [ style [ ( "cursor", "pointer" ) ]
            , onClick (ExternalMessage.ChangeUrl "/voting")
            ]
            [ div [ class "card vote" ]
                [ h3 [] [ text (translate language Vote) ]
                , p [] [ text (translate language VoteDesc) ]
                ]
            ]
        , a [ style [ ( "cursor", "pointer" ) ] ]
            [ div [ class "card proxy_vote" ]
                [ h3 [] [ text (translate language ProxyVote) ]
                , p [] [ text (translate language ProxyVoteDesc) ]
                ]
            ]
        , a [ style [ ( "cursor", "pointer" ) ] ]
            [ div [ class "card faq" ]
                [ h3 [] [ text (translate language Faq) ]
                , p [] [ text (translate language FaqDesc) ]
                ]
            ]
        ]
