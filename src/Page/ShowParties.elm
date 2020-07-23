module Page.ShowParties exposing (Model, Msg(..), decode, default, update, view)

import Data.Party as Party
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchParties String
    | PartiesReceived (List Party.Model)


type alias Model =
    { parties : List Party.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderPartyList model.parties ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchParties year ->
            ( model, Cmd.none )

        PartiesReceived parties ->
            ( { model | parties = parties }, Cmd.none )


renderPartyList : List Party.Model -> Html.Html Msg
renderPartyList parties =
    div []
        (List.map renderPartyItem parties)


renderPartyItem : Party.Model -> Html.Html Msg
renderPartyItem party =
    div []
        [ div [] [ Html.text party.name ]
        , div [] [ Html.text party.color ]
        , div [] [ Html.text party.logoPath ]
        ]


decode : Decode.Decoder (List Party.Model)
decode =
    Decode.field "parties" (Decode.list Party.decode)


default : Model
default =
    { parties = [], year = "" }
