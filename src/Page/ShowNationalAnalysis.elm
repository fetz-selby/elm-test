module Page.ShowNationalAnalysis exposing (Model, Msg(..), decode, default, update, view)

import Data.NationalAnalysis as NationalAnalysis
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchNationalAnalysis String
    | NationalAnalysisReceived (List NationalAnalysis.Model)


type alias Model =
    { nationalAnalysis : List NationalAnalysis.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderNationalList model.nationalAnalysis ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchNationalAnalysis year ->
            ( model, Cmd.none )

        NationalAnalysisReceived nationalAnalysis ->
            ( { model | nationalAnalysis = nationalAnalysis }, Cmd.none )


renderNationalList : List NationalAnalysis.Model -> Html.Html Msg
renderNationalList nationalAnalysis =
    div []
        (List.map renderNationalItem nationalAnalysis)


renderNationalItem : NationalAnalysis.Model -> Html.Html Msg
renderNationalItem national =
    div []
        [ div [] [ Html.text national.party.name ]
        , div [] [ Html.text national.candidateType ]
        , div [] [ Html.text (String.fromInt national.votes) ]
        ]


decode : Decode.Decoder (List NationalAnalysis.Model)
decode =
    Decode.field "nationalAnalysis" (Decode.list NationalAnalysis.decode)


default : Model
default =
    { nationalAnalysis = [], year = "" }
