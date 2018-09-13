module Component.Main.Page.Resource.Modal.DelegateList exposing
    ( Message(..)
    , Model
    , initModel
    , update
    , viewDelegateListModal
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Translation exposing (I18n(..), Language, translate)



-- MODEL


type alias Model =
    { cpuInput : String
    , netInput : String
    , isDelegateListModalOpened : Bool
    }


initModel : Model
initModel =
    { cpuInput = ""
    , netInput = ""
    , isDelegateListModalOpened = False
    }



-- UPDATE


type Message
    = CloseModal


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CloseModal ->
            ( { model | isDelegateListModalOpened = False }, Cmd.none )



-- VIEW


viewDelegateListModal : Language -> Model -> Html Message
viewDelegateListModal language ({ isDelegateListModalOpened } as model) =
    section
        [ attribute "aria-live" "true"
        , class
            ("rental_account modal popup"
                ++ (if isDelegateListModalOpened then
                        " viewing"

                    else
                        ""
                   )
            )
        , id "popup"
        , attribute "role" "alert"
        ]
        [ div [ class "wrapper" ]
            [ h2 []
                [ text "임대해준 계정 리스트" ]
            , Html.form [ action "" ]
                [ input [ class "search_token", id "", name "", placeholder "계정명 검색하기", type_ "text" ]
                    []
                , button [ type_ "button" ]
                    [ text "검색" ]
                ]
            , div [ class "result list", attribute "role" "listbox" ]
                [ ul []
                    [ li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    , li []
                        [ h3 []
                            [ text "blockoine123" ]
                        , p []
                            [ text "CPU : 123123123 EOS" ]
                        , p []
                            [ text "NET : 123123123 EOS" ]
                        , button [ type_ "button" ]
                            [ text "취소하기" ]
                        ]
                    ]
                ]
            , button [ class "close", id "closePopup", type_ "button", onClick CloseModal ]
                [ text "닫기" ]
            ]
        ]
