module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchNationalAnalysis String
    | AddNationalAnalysis
    | ShowDetail NationalAnalysis.Model
    | NationalAnalysisReceived (List NationalAnalysis.Model)


type alias Model =
    { nationalAnalysis : List NationalAnalysis.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderNationalList model.nationalAnalysis ]
            , div [ class "col-md-4" ] []
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchNationalAnalysis year ->
            ( model, Cmd.none )

        AddNationalAnalysis ->
            ( model, Cmd.none )

        ShowDetail nationalAnalysis ->
            ( model, Cmd.none )

        NationalAnalysisReceived nationalAnalysis ->
            ( { model | nationalAnalysis = nationalAnalysis }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddNationalAnalysis ] [ Html.text "Add" ]
            ]
        ]


renderNationalList : List NationalAnalysis.Model -> Html.Html Msg
renderNationalList nationalAnalysis =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderNationalAnalysisHeader ]
        , tbody [] (List.map renderNationalItem nationalAnalysis)
        ]


renderNationalAnalysisHeader : Html.Html Msg
renderNationalAnalysisHeader =
    tr []
        [ th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Votes" ]
        ]


renderNationalItem : NationalAnalysis.Model -> Html.Html Msg
renderNationalItem national =
    tr [ onClick (ShowDetail national) ]
        [ td [] [ Html.text national.party.name ]
        , td [] [ Html.text national.candidateType ]
        , td [] [ Html.text (String.fromInt national.votes) ]
        ]


decode : Decode.Decoder (List NationalAnalysis.Model)
decode =
    Decode.field "nationalAnalysis" (Decode.list NationalAnalysis.decode)


default : Model
default =
    { nationalAnalysis = [], year = "" }
