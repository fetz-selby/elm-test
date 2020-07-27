module Page.ShowParties exposing (Model, Msg(..), decode, default, update, view)

import Data.Party as Party
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, readonly, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchParties String
    | AddParty
    | ShowDetail Party.Model
    | PartiesReceived (List Party.Model)
    | Form Field
    | Save


type Field
    = Party String
    | Color String
    | LogoPath String


type alias Model =
    { parties : List Party.Model
    , year : String
    , selectedParty : Party.Model
    , isEditableMode : Bool
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ] [ renderPartyList model.parties ]
            , div [ class "col-md-4" ]
                [ if model.isEditableMode then
                    renderEditableDetails model.selectedParty

                  else
                    renderDetails model.selectedParty
                ]
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
            ( { model | selectedParty = party }, Cmd.none )

        PartiesReceived parties ->
            ( { model | parties = parties }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


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


renderField : String -> String -> String -> Bool -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder isEditable field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , if isEditable then
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []

          else
            input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, readonly True ] []
        ]


renderDetails : Party.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.name "eg.XXX" False Party
        , renderField "color" model.color "e.g P" False Color
        , renderField "logo path" model.logoPath "e.g #F33e345" False LogoPath
        ]


renderEditableDetails : Party.Model -> Html.Html Msg
renderEditableDetails model =
    form [ onSubmit Save ]
        [ renderField "party" model.name "eg.XXX" True Party
        , renderField "color" model.color "e.g P" True Color
        , renderField "logo path" model.logoPath "e.g #F33e345" True LogoPath
        ]


decode : Decode.Decoder (List Party.Model)
decode =
    Decode.field "parties" (Decode.list Party.decode)


default : Model
default =
    { parties = [], year = "", selectedParty = Party.initParty, isEditableMode = False }
