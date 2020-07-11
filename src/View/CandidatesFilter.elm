module View.CandidatesFilter exposing (Model, encode, update, view)

import Data.Constituency as Constituency
import Html exposing (div)
import Html.Attributes exposing (value)
import Html.Events exposing (onClick)
import Html.Events.Extra exposing (onChange)
import Json.Encode as Encode


type Msg
    = Submit
    | OnConstituencyChange String


type alias Model =
    { constituencyId : String
    , candidateType : String
    , year : String
    }


view : List Constituency.Model -> Html.Html Msg
view constituencies =
    div []
        [ loadConstituencies constituencies
        , submitButton
        ]


update : Msg -> Model -> Model
update msg model =
    case msg of
        Submit ->
            model

        OnConstituencyChange val ->
            model


loadConstituencies : List Constituency.Model -> Html.Html Msg
loadConstituencies constituencyList =
    div []
        [ Html.select [ onChange OnConstituencyChange ] (List.map constituencyItem constituencyList)
        ]


constituencyItem : Constituency.Model -> Html.Html msg
constituencyItem item =
    Html.option [ value item.id ] [ Html.text item.name ]


submitButton : Html.Html Msg
submitButton =
    Html.button [ onClick Submit ] [ Html.text "Load" ]


encode : Model -> Encode.Value
encode model =
    Encode.object
        [ ( "constituency_id", Encode.string model.constituencyId )
        , ( "type", Encode.string model.candidateType )
        , ( "year", Encode.string model.year )
        ]
