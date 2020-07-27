module Page.ShowConstituencies exposing (Model, Msg(..), decode, default, update, view)

import Data.Constituency as Constituency
import Html exposing (button, div, form, input, label, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class, placeholder, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode as Decode


type Msg
    = FetchConstituencies String
    | AddConstituency
    | ShowDetail Constituency.Model
    | ConstituenciesReceived (List Constituency.Model)
    | Form Field
    | Save


type Field
    = Constituency String
    | CastedVotes String
    | IsDeclared String
    | ParentId String
    | RegVotes String
    | RejectVotes String
    | SeatWonId String
    | TotalVotes String
    | AutoCompute String


type alias Model =
    { constituencies : List Constituency.Model
    , region : String
    , year : String
    , selectedConstituency : Constituency.Model
    }


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchConstituencies constituencyId ->
            ( model, Cmd.none )

        AddConstituency ->
            ( model, Cmd.none )

        ShowDetail constituency ->
            ( { model | selectedConstituency = constituency }, Cmd.none )

        ConstituenciesReceived constituencies ->
            ( { model | constituencies = constituencies }, Cmd.none )

        Form field ->
            ( model, Cmd.none )

        Save ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ]
                [ renderConstituencyList model.constituencies
                ]
            , div [ class "col-md-4" ] [ renderDetails model.selectedConstituency ]
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


renderField : String -> String -> String -> (String -> Field) -> Html.Html Msg
renderField fieldLabel fieldValue fieldPlaceholder field =
    div [ class "form-group" ]
        [ label [] [ Html.text fieldLabel ]
        , input [ class "form-control", type_ "text", value fieldValue, placeholder fieldPlaceholder, onInput (Form << field) ] []
        ]


renderDetails : Constituency.Model -> Html.Html Msg
renderDetails model =
    form [ onSubmit Save ]
        [ renderField "constituency" model.name "eg.Bekwai" Constituency
        , renderField "seat won by" model.seatWonId "eg.XXX" SeatWonId
        , renderField "casted votes" (String.fromInt model.castedVotes) "e.g P" CastedVotes
        , renderField "reg votes" (String.fromInt model.regVotes) "e.g 432" RegVotes
        , renderField "rejected votes" (String.fromInt model.rejectVotes) "e.g 180" RejectVotes
        , renderField "total votes" (String.fromInt model.totalVotes) "e.g 234" TotalVotes
        , renderField "is declared"
            (if model.isDeclared then
                "Yes"

             else
                "No"
            )
            "e.g Yes"
            IsDeclared
        , renderField "is declared"
            (if model.autoCompute then
                "Yes"

             else
                "No"
            )
            "e.g No"
            AutoCompute
        , renderField "parent id" model.parentId "e.g 1001" ParentId
        ]


decode : Decode.Decoder (List Constituency.Model)
decode =
    Decode.field "constituencies" (Decode.list Constituency.decode)


default : Model
default =
    { constituencies = [], region = "", year = "", selectedConstituency = Constituency.initConstituency }
