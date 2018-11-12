module Component.Main.Page.Index exposing (Message(ChangeUrl), view)

import Html exposing (Html, a, br, button, div, h2, h3, main_, node, p, section, text)
import Html.Attributes exposing (attribute, class, href, target, type_)
import Html.Events exposing (onClick)
import Translation exposing (I18n(..), Language, toLocale, translate)



-- MESSAGE --


type Message
    = ChangeUrl String



-- VIEW --


view : Language -> Html Message
view language =
    main_ [ class "index" ]
        [ section [ class "menu_area" ]
            [ h2 [] [ text "Menu" ]
            , div [ class "container" ]
                [ div [ class "greeting event_free" ]
                    [ h3 []
                        [ text (translate language Hello)
                        , br [] []
                        , text (translate language WelcomeEosHub)
                        ]
                    , p []
                        [ a [ onClick (ChangeUrl ("/account/event_creation?locale=" ++ toLocale language)) ]
                            [ text (translate language MakeYourAccount) ]
                        ]
                    ]
                , a
                    [ onClick (ChangeUrl "/transfer")
                    , class "card transfer"
                    ]
                    [ h3 [] [ text (translate language Transfer) ]
                    , p [] [ text (translate language TransferHereDesc) ]
                    ]
                , a
                    [ onClick (ChangeUrl "/vote")
                    , class "card vote"
                    ]
                    [ h3 [] [ text (translate language Vote) ]
                    , p [] [ text (translate language VoteDesc) ]
                    ]
                , a
                    [ onClick (ChangeUrl "/resource")
                    , class "card resource"
                    ]
                    [ h3 [] [ text "CPU / NET" ]
                    , p [] [ text (translate language ManageResourceDesc) ]
                    ]
                , a
                    [ onClick (ChangeUrl "/rammarket")
                    , class "card ram_market"
                    ]
                    [ h3 [] [ text (translate language RamMarket) ]
                    , p [] [ text (translate language RamMarketDesc) ]
                    ]
                ]
            ]
        , section [ class "promotion", attribute "data-display" "1", attribute "data-max" "3" ]
            [ h3 []
                [ text "AD" ]
            , div [ class "rolling banner" ]
                [ a [ class "eosdaq", href "https://eosdaq.com/", target "_blank" ] [ text "A New Standard of DEX" ]
                , a [ class "dapp", href (translate language DappContestLink), target "_blank" ]
                    [ text "Dapp contest" ]
                , a [ class "nova", href "http://eosnova.io/", target "_blank" ]
                    [ text "Yout first EOS wallet,NOVA Wallet" ]
                ]
            , div [ class "banner handler" ]
                [ button [ class "rotate banner circle button", type_ "button" ]
                    [ text "EOSDAQ free account event" ]
                , button [ class "rotate banner circle button", type_ "button" ]
                    [ text "Dapp contest banner" ]
                , button [ class "rotate banner circle button", type_ "button" ]
                    [ text "Nova wallet" ]
                ]
            ]

        -- TODO(boseok): Change js code to Elm
        , node "script"
            []
            [ text "!function(){var e=document.querySelectorAll('.promotion .banner.handler button'),t=document.querySelectorAll('.promotion .rolling.banner a'),n=document.querySelector('.promotion'),o=document.querySelector('.promotion').dataset.max;function a(){n.dataset.display>=o?n.dataset.display=1:n.dataset.display++}for(var r=setInterval(a,7e3),l=0;l<e.length;l++)!function(e,n,o){t[o].addEventListener('mouseover',function(){clearInterval(r)}),t[o].addEventListener('mouseout',function(){r=setInterval(a,7e3)}),e[o].addEventListener('mouseover',function(){clearInterval(r),n.dataset.display=o+1}),e[o].addEventListener('mouseout',function(){r=setInterval(a,7e3)})}(e,n,l)}();" ]
        ]
