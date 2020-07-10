module View.ConstituenciesFilter exposing (update, view)

import Html exposing (div)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)


type alias ConstituencyFilter =
    { region : String
    , id : String
    }


type alias Model =
    { regions : List ConstituencyFilter
    , selectedRegionId : String
    }


type Msg
    = Submit
    | OnRegionChange String


view : Model -> Html.Html Msg
view model =
    div []
        [ loadRegions model.regions
        , submitButton
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Submit ->
            model

        OnRegionChange val ->
            model


loadRegions : List ConstituencyFilter -> Html.Html Msg
loadRegions regionsList =
    div []
        [ Html.select [ onChange OnRegionChange ] (List.map regionItem regionsList)
        ]


regionItem : ConstituencyFilter -> Html.Html msg
regionItem item =
    Html.option [ value item.id ] [ Html.text item.region ]


submitButton : Html.Html Msg
submitButton =
    Html.button [ onClick Submit ] [ Html.text "Load" ]
