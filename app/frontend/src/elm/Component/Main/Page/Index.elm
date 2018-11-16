module Component.Main.Page.Index exposing 
    (Message(..)
    , Model
    , initModel
    , update
    , view
    , subscriptions
    )

import Data.Json exposing (ProductionState)
import Html exposing (Html, a, br, button, div, h2, h3, main_, node, p, section, span, text)
import Html.Attributes exposing (attribute, class, href, id, target, type_)
import Html.Events exposing (onClick, onMouseOver, onMouseOut)
import Translation exposing (I18n(..), Language, toLocale, translate)
import Time



-- MODEL --


type alias Model =
    { bannerIndex : Int
    , bannerSecondsLeft : Int
    , isTimerOn : Bool
    }


initModel : Model
initModel =
    { bannerIndex = 1
    , bannerSecondsLeft = intervalValue
    , isTimerOn = True
    }


intervalValue : Int
intervalValue = 7


bannerMaxCount : Int
bannerMaxCount = 3


-- MESSAGE --


type Message
    = ChangeUrl String
    | CloseModal
    | ChangeBanner Int
    | Tick Time.Time
    | ToggleBannerTimer Bool


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        ChangeBanner index ->
            ( { model
                | bannerSecondsLeft = intervalValue
                , bannerIndex = index
                , isTimerOn = False
              }
            , Cmd.none 
            )

        Tick _ ->
            let
                secondsLeft = 
                    model.bannerSecondsLeft - 1

                newIndex =
                    if model.bannerIndex + 1 > bannerMaxCount then
                            1

                    else
                        model.bannerIndex + 1

            in
            if secondsLeft <= 0 then
                ( { model
                    | bannerSecondsLeft = intervalValue
                    , bannerIndex = newIndex
                  }
                , Cmd.none 
                )
            else
                ( { model | bannerSecondsLeft = secondsLeft }, Cmd.none )

        ToggleBannerTimer on ->
            let
                resetInterval =
                    if on then
                        model.bannerSecondsLeft
                            
                    else
                        intervalValue
                        
            in
            ( { model | isTimerOn = on, bannerSecondsLeft = resetInterval }, Cmd.none )
    
        _ ->
            ( model, Cmd.none )


-- VIEW --


view : Model -> Language -> ProductionState -> Html Message
view model language productionState =
    main_ [ class "index" ]
        [ section [ class "menu_area" ]
            [ h2 [] [ text "Menu" ]
            , div [ class "container" ]
                [ div
                    [ class
                        ("greeting"
                            ++ (case productionState.isEvent of
                                    True ->
                                        " event_free"

                                    False ->
                                        ""
                               )
                        )
                    ]
                    [ h3 []
                        [ text (translate language Hello)
                        , br [] []
                        , text (translate language WelcomeEosHub)
                        ]
                    , viewEventClickButton language productionState.isEvent
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
        , section [ class "promotion"
            , attribute "data-display" (toString model.bannerIndex)
            , attribute "data-max" (toString (bannerMaxCount)) 
            ]
            [ h3 []
                [ text "AD" ]
            , div [ class "rolling banner" ]
                [ viewBanner "eosdaq" "https://eosdaq.com/" "A New Standard of DEX"
                , viewBanner "dapp" (translate language DappContestLink) "Dapp contest"
                , viewBanner "nova" "http://eosnova.io/" "Yout first EOS wallet,NOVA Wallet"
                ]
            , div [ class "banner handler" ]
                [ viewBannerButton "EOSDAQ free account event" 1
                , viewBannerButton "Dapp contest banner" 2
                , viewBannerButton "Nova wallet" 3
                ]
            ]
        , viewAnnouncementSection language productionState
        ]


viewEventClickButton : Language -> Bool -> Html Message
viewEventClickButton language isEvent =
    case isEvent of
        True ->
            p []
                [ a [ onClick (ChangeUrl ("/account/event_creation?locale=" ++ toLocale language)) ]
                    [ text (translate language MakeYourAccount) ]
                ]

        False ->
            span [] []


viewAnnouncementSection : Language -> ProductionState -> Html Message
viewAnnouncementSection language { isAnnouncement, isAnnouncementCached } =
    -- TODO(boseok): It should be changed to use isAnnouncement which will get from Admin Backend server.
    let
        isAnnouncementModalOpen =
            isAnnouncement && isAnnouncementCached
    in
    section
        [ attribute "aria-live" "true"
        , class
            ("notice modal popup"
                ++ (case isAnnouncementModalOpen of
                        True ->
                            " viewing"

                        False ->
                            ""
                   )
            )
        , id "popup"
        , attribute "role" "alert"
        ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text (translate language AnnouncementModalTitle) ]
            , p []
                [ text (translate language AnnouncementModalParagraph) ]
            , button [ class "close", id "closePopup", type_ "button", onClick CloseModal ]
                [ text "닫기" ]
            ]
        ]


viewBanner : String -> String -> String -> Html Message
viewBanner cls url str =
    a [ class cls
        , href url
        , target "_blank" 
        , onMouseOver (ToggleBannerTimer False)
        , onMouseOut (ToggleBannerTimer True)
        ] 
        [ text str ]


viewBannerButton : String -> Int -> Html Message
viewBannerButton str index =
    button [ class "rotate banner circle button"
        , type_ "button" 
        , onMouseOver (ChangeBanner index)
        , onMouseOut (ToggleBannerTimer True)
        ]
        [ text str ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    if model.isTimerOn then
        Time.every Time.second Tick
            
    else
        Sub.none