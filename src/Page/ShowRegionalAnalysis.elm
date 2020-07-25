module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchRegionalAnalysis String
    | RegionalAnalysisReceived (List RegionalAnalysis.Model)


type alias Model =
    { regionalAnalysis : List RegionalAnalysis.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderRegionalList model.regionalAnalysis ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegionalAnalysis year ->
            ( model, Cmd.none )

        RegionalAnalysisReceived regionalAnalysis ->
            ( { model | regionalAnalysis = regionalAnalysis }, Cmd.none )


renderRegionalList : List RegionalAnalysis.Model -> Html.Html Msg
renderRegionalList regionalAnalysis =
    div []
        (List.map renderRegionalItem regionalAnalysis)


renderRegionalItem : RegionalAnalysis.Model -> Html.Html Msg
renderRegionalItem regional =
    div []
        [ div [] [ Html.text regional.region.name ]
        , div [] [ Html.text regional.party.name ]
        , div [] [ Html.text regional.candidateType ]
        , div [] [ Html.text (String.fromInt regional.votes) ]
        ]


decode : Decode.Decoder (List RegionalAnalysis.Model)
decode =
    Decode.field "regionalAnalysis" (Decode.list RegionalAnalysis.decode)


default : Model
default =
    { regionalAnalysis = [], year = "" }
