module View exposing (view)

import Html exposing (div)
import Model
import Msg exposing (Msg(..))


view : Model.Model -> Html.Html Msg
view model =
    div []
        [ pageView model
        ]


pageView : Model.Model -> Html.Html Msg
pageView { pages } =
    div [] []
