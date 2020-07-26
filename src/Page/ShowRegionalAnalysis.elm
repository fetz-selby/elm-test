module Page.ShowRegionalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.RegionalAnalysis as RegionalAnalysis
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchRegionalAnalysis String
    | AddRegionalAnalysis
    | ShowDetail RegionalAnalysis.Model
    | RegionalAnalysisReceived (List RegionalAnalysis.Model)


type alias Model =
    { regionalAnalysis : List RegionalAnalysis.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderRegionalList model.regionalAnalysis
                ]
            , div [ class "col-md-4" ] []
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchRegionalAnalysis year ->
            ( model, Cmd.none )

        AddRegionalAnalysis ->
            ( model, Cmd.none )

        ShowDetail regionalAnalysis ->
            ( model, Cmd.none )

        RegionalAnalysisReceived regionalAnalysis ->
            ( { model | regionalAnalysis = regionalAnalysis }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddRegionalAnalysis ] [ Html.text "Add" ]
            ]
        ]


renderRegionalList : List RegionalAnalysis.Model -> Html.Html Msg
renderRegionalList regionalAnalysis =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderRegionAnalysisHeader ]
        , tbody [] (List.map renderRegionalItem regionalAnalysis)
        ]


renderRegionAnalysisHeader : Html.Html Msg
renderRegionAnalysisHeader =
    tr []
        [ th [] [ Html.text "Region" ]
        , th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Total Votes" ]
        ]


renderRegionalItem : RegionalAnalysis.Model -> Html.Html Msg
renderRegionalItem regional =
    tr [ onClick (ShowDetail regional) ]
        [ td [] [ Html.text regional.region.name ]
        , td [] [ Html.text regional.party.name ]
        , td [] [ Html.text regional.candidateType ]
        , td [] [ Html.text (String.fromInt regional.votes) ]
        ]


decode : Decode.Decoder (List RegionalAnalysis.Model)
decode =
    Decode.field "regionalAnalysis" (Decode.list RegionalAnalysis.decode)


default : Model
default =
    { regionalAnalysis = [], year = "" }
