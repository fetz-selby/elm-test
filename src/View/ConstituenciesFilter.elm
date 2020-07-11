module View.ConstituenciesFilter exposing (Model, encode, update, view)

import Html exposing (div)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)
import Json.Encode as Encode


type alias ConstituencyFilter =
    { region : String
    , id : String
    }


type alias Model =
    { regionId : String
    , year : String
    }


type Msg
    = Submit
    | OnRegionChange String


view : List ConstituencyFilter -> Html.Html Msg
view regions =
    div []
        [ loadRegions regions
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


encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ( "region_id", Encode.string model.regionId )
        , ( "year", Encode.string model.year )
        ]
