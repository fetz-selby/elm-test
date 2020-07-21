module Page.ShowConstituencies exposing (Model, Msg(..), decode, default, update, view)

import Data.Constituency as Constituency
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchConstituencies String
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

        ConstituenciesReceived candidates ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderConstituencyList model.constituencies ]


renderConstituencyList : List Constituency.Model -> Html.Html Msg
renderConstituencyList constituencies =
    div []
        (List.map renderConstituencyItem constituencies)


renderConstituencyItem : Constituency.Model -> Html.Html Msg
renderConstituencyItem constituency =
    div []
        [ div [] [ Html.text constituency.name ]
        , div [] [ Html.text constituency.year ]
        ]


decode : Decode.Decoder (List Constituency.Model)
decode =
    Decode.field "constituencies" (Decode.list Constituency.decode)


default : Model
default =
    { constituencies = [], region = "", year = "" }
