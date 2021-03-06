module Component.Main.Page.Resource.Modal.DelegateList exposing
    ( Message(..)
    , Model
    , initModel
    , update
    , view
    )

import Data.Table exposing (Row(..), initDelbandFields)
import Html exposing (Html, button, div, h2, h3, input, li, p, section, text, ul)
import Html.Attributes exposing (action, attribute, class, id, name, placeholder, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Translation exposing (I18n(..), Language, translate)



-- MODEL


type alias Model =
    { isDelegateListModalOpened : Bool
    , query : String
    }


initModel : Model
initModel =
    { isDelegateListModalOpened = False
    , query = ""
    }



-- UPDATE


type Message
    = CloseModal
    | ClickDelband String String String
    | AccountInput String
    | NoOp


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CloseModal ->
            ( initModel, Cmd.none )

        AccountInput query ->
            ( { model | query = query }, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Language -> Model -> List Row -> String -> Html Message
view language { isDelegateListModalOpened, query } list accountName =
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
                [ text (translate language DelegatedList) ]
            , Html.form
                [ onSubmit NoOp
                , action ""
                ]
                [ input
                    [ class "search_token"
                    , id ""
                    , name ""
                    , placeholder (translate language TypeAccount)
                    , type_ "text"
                    , onInput AccountInput
                    , Html.Attributes.value query
                    , attribute "maxlength" "12"
                    ]
                    []
                , button [ type_ "button" ]
                    [ text (translate language Select) ]
                ]
            , div [ class "result list", attribute "role" "listbox" ]
                [ ul []
                    (viewDelbandList language list query accountName)
                ]
            , button [ class "close", id "closePopup", type_ "button", onClick CloseModal ]
                [ text (translate language Close) ]
            ]
        ]


viewDelbandList : Language -> List Row -> String -> String -> List (Html Message)
viewDelbandList language list query accountName =
    let
        showList =
            List.filter
                (\x ->
                    case x of
                        Delband value ->
                            String.contains (String.toLower query) (String.toLower value.receiver)

                        _ ->
                            False
                )
                list
    in
    List.map (viewDelbandLi language accountName) showList


viewDelbandLi : Language -> String -> Row -> Html Message
viewDelbandLi language accountName row =
    let
        delband =
            case row of
                Delband value ->
                    value

                _ ->
                    initDelbandFields
    in
    if accountName /= delband.receiver then
        li []
            [ h3 []
                [ text delband.receiver ]
            , p []
                [ text ("CPU : " ++ delband.cpuWeight) ]
            , p []
                [ text ("NET : " ++ delband.netWeight) ]
            , button
                [ type_ "button"
                , onClick (ClickDelband delband.receiver delband.cpuWeight delband.netWeight)
                ]
                [ text (translate language Select) ]
            ]

    else
        text ""
