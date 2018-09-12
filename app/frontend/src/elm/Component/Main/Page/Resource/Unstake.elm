module Component.Main.Page.Resource.Unstake exposing (Message(..), Model, initModel, update, view)

import Data.Account
    exposing
        ( Account
        , Refund
        , Resource
        , ResourceInEos
        , accountDecoder
        , defaultAccount
        , getResource
        , getTotalAmount
        , getUnstakingAmount
        , keyAccountsDecoder
        )
import Html exposing (..)
import Html.Attributes exposing (..)
import Translation exposing (I18n(..), Language, translate)
import Util.Formatter exposing (assetAdd, assetSubtract)



-- MODEL


type alias Model =
    { unstakeInput : String
    }


initModel : Model
initModel =
    { unstakeInput = "" }



-- UPDATE


type Message
    = InputUnstakeAmount String


update : Message -> Model -> Account -> ( Model, Cmd Message )
update message model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    case message of
        InputUnstakeAmount value ->
            ( { model | unstakeInput = value }, Cmd.none )



-- VIEW


view : Language -> Model -> Account -> Html Message
view language model ({ totalResources, selfDelegatedBandwidth, coreLiquidBalance } as account) =
    div [ class "unstake container" ]
        [ div [ class "my resource" ]
            [ div []
                [ h3 []
                    [ text "CPU 총량"
                    , strong []
                        [ text totalResources.cpuWeight ]
                    ]
                , p []
                    [ text ("내가 스테이크한 토큰 : " ++ selfDelegatedBandwidth.cpuWeight) ]
                , p []
                    [ text ("임대받은 토큰 : " ++ assetSubtract totalResources.cpuWeight selfDelegatedBandwidth.cpuWeight) ]
                , div [ class "graph status" ]
                    [ span [ class "hell", attribute "style" "height:10%" ]
                        []
                    , text "10%"
                    ]
                ]
            , div []
                [ h3 []
                    [ text "NET 총량"
                    , strong []
                        [ text totalResources.netWeight ]
                    ]
                , p []
                    [ text ("내가 스테이크한 토큰 : " ++ selfDelegatedBandwidth.netWeight) ]
                , p []
                    [ text ("임대받은 토큰 : " ++ assetSubtract totalResources.netWeight selfDelegatedBandwidth.netWeight) ]
                , div [ class "graph status" ]
                    [ span [ class "hell", attribute "style" "height:10%" ]
                        []
                    , text "10%"
                    ]
                ]
            ]
        , section []
            [ div [ class "wallet status" ]
                [ h3 []
                    [ text "언스테이크 가능한 토큰" ]
                , p []
                    [ text "100 EOS" ]
                , p [ class "validate description" ]
                    [ text "CPU는 최소 0.7 EOS, NET은 최소 0.3 EOS 이상 스테이킹 하세요." ]
                ]
            , div [ class "field group" ]
                [ div [ class "input field" ]
                    [ label [ for "cpu" ]
                        [ text "CPU" ]
                    , input [ id "cpu", Html.Attributes.max "1000000000", Html.Attributes.min "0.0001", pattern "\\d+(\\.\\d{1,4})?", placeholder "CPU 언스테이크 할 수량 입력", step "0.0001", type_ "number" ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , button [ type_ "button" ]
                        [ text "10%" ]
                    , button [ type_ "button" ]
                        [ text "50%" ]
                    , button [ type_ "button" ]
                        [ text "70%" ]
                    , button [ type_ "button" ]
                        [ text "최대" ]
                    ]
                , div [ class "input field" ]
                    [ label [ for "net" ]
                        [ text "NET" ]
                    , input [ attribute "data-validate" "false", id "net", Html.Attributes.max "1000000000", Html.Attributes.min "0.0001", pattern "\\d+(\\.\\d{1,4})?", placeholder "NET 언스테이크할 수량 입력", step "0.0001", type_ "number" ]
                        []
                    , span [ class "unit" ]
                        [ text "EOS" ]
                    , button [ type_ "button" ]
                        [ text "10%" ]
                    , button [ type_ "button" ]
                        [ text "50%" ]
                    , button [ type_ "button" ]
                        [ text "70%" ]
                    , button [ type_ "button" ]
                        [ text "최대" ]
                    ]
                ]
            , div [ class "btn_area" ]
                [ button [ class "ok button", attribute "disabled" "", type_ "button" ]
                    [ text "확인" ]
                ]
            ]
        , node "script"
            []
            [ text "(function(){var button=document.querySelectorAll('div.input.field button');var clicked;for(var i=0;i<button.length;i++){button[i].addEventListener('click',function(){if(!!clicked){clicked.classList.remove('clicked')}this.classList.add('clicked');clicked=this})}})();(function(){var button=document.querySelectorAll('div.input.field button');var input=document.querySelector('input[type=\"number\"]');var submit=document.querySelector('.btn_area button');var max=parseInt(1000);button[0].addEventListener('click',function(){input.value=max*0.1 input.focus()});button[1].addEventListener('click',function(){input.value=max*0.5;input.focus()});button[2].addEventListener('click',function(){input.value=max*0.7;input.focus()});button[3].addEventListener('click',function(){input.value=max*1;input.focus()})})();(function(){var submit=document.querySelector('.btn_area button');var input=document.querySelector('input[type=\"number\"]');input.addEventListener('focus',function(){console.log(this.vaule);if(this.value>0){submit.removeAttribute('disabled')}});input.addEventListener('keyup',function(){!this.value>0?submit.setAttribute('disabled',''):submit.removeAttribute('disabled')})})();" ]
        ]
