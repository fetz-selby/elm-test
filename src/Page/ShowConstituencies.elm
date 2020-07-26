module Page.ShowConstituencies exposing (Model, Msg(..), decode, default, update, view)

import Data.Constituency as Constituency
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchConstituencies String
    | AddConstituency
    | ShowDetail Constituency.Model
    | ConstituenciesReceived (List Constituency.Model)


type alias Model =
    { constituencies : List Constituency.Model
    , region : String
    , year : String
    }


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchConstituencies constituencyId ->
            ( model, Cmd.none )

        AddConstituency ->
            ( model, Cmd.none )

        ShowDetail constituency ->
            ( model, Cmd.none )

        ConstituenciesReceived constituencies ->
            ( { model | constituencies = constituencies }, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderConstituencyList model.constituencies
                ]
            , div [ class "col-md-4" ] []
            ]
        ]


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddConstituency ] [ Html.text "Add" ]
            ]
        ]


renderConstituencyList : List Constituency.Model -> Html.Html Msg
renderConstituencyList constituencies =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderConstituencyHeader ]
        , tbody [] (List.map renderConstituencyItem constituencies)
        ]


renderConstituencyHeader : Html.Html Msg
renderConstituencyHeader =
    tr []
        [ th [] [ Html.text "Constituency" ]
        , th [] [ Html.text "Seat Won" ]
        , th [] [ Html.text "Total Votes" ]
        ]


renderConstituencyItem : Constituency.Model -> Html.Html Msg
renderConstituencyItem constituency =
    tr [ onClick (ShowDetail constituency) ]
        [ td [] [ Html.text constituency.name ]
        , td [] [ Html.text "XXX" ]
        , td [] [ Html.text (String.fromInt constituency.totalVotes) ]
        ]


decode : Decode.Decoder (List Constituency.Model)
decode =
    Decode.field "constituencies" (Decode.list Constituency.decode)


default : Model
default =
    { constituencies = [], region = "", year = "" }
