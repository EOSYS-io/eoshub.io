module Component.Main.Page.NotFound exposing (view)

import Html exposing (Html, h2, main_, section, text)
import Html.Attributes exposing (class)
import Translation exposing (I18n(NotFoundDesc), Language, translate)



-- VIEW


view : Language -> Html message
view language =
    main_ [ class "error_404" ]
        [ section [ class "error message wrapper" ]
            [ h2 [] [ text (translate language NotFoundDesc) ]
            ]
        ]
