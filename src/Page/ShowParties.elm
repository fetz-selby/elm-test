module Page.ShowParties exposing (Model, Msg(..), decode, default, update, view)

import Data.Party as Party
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchParties String
    | AddParty
    | ShowDetail Party.Model
    | PartiesReceived (List Party.Model)


type alias Model =
    { parties : List Party.Model
    , year : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ] [ renderPartyList model.parties ]
            , div [ class "col-md-4" ] []
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchParties year ->
            ( model, Cmd.none )

        AddParty ->
            ( model, Cmd.none )

        ShowDetail party ->
            ( model, Cmd.none )

        PartiesReceived parties ->
            ( { model | parties = parties }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddParty ] [ Html.text "Add" ]
            ]
        ]


renderPartyList : List Party.Model -> Html.Html Msg
renderPartyList parties =
    table [ class "table table-striped table table-hover" ]
        [ thead []
            [ renderPartyHeader ]
        , tbody [] (List.map renderPartyItem parties)
        ]


renderPartyHeader : Html.Html Msg
renderPartyHeader =
    tr []
        [ th [] [ Html.text "Party" ]
        , th [] [ Html.text "Type" ]
        , th [] [ Html.text "Votes" ]
        ]


renderPartyItem : Party.Model -> Html.Html Msg
renderPartyItem party =
    tr [ onClick (ShowDetail party) ]
        [ td [] [ Html.text party.name ]
        , td [] [ Html.text party.color ]
        , td [] [ Html.text party.logoPath ]
        ]


decode : Decode.Decoder (List Party.Model)
decode =
    Decode.field "parties" (Decode.list Party.decode)


default : Model
default =
    { parties = [], year = "" }
