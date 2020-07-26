module Page.ShowApproves exposing (Model, Msg(..), decode, default, update, view)

import Data.Approve as Approve
import Html exposing (button, div, input, table, tbody, td, th, thead, tr)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type Msg
    = FetchApproves
    | AddApprove
    | ShowDetail Approve.Model
    | ApprovesReceived (List Approve.Model)


type alias Model =
    { approves : List Approve.Model
    , year : String
    , voteType : String
    }


view : Model -> Html.Html Msg
view model =
    div
        []
        [ renderHeader
        , div [ class "row" ]
            [ div [ class "col-md-8" ] [ renderApproveList model.approves ]
            , div [ class "col-md-4" ] []
            ]
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchApproves ->
            ( model, Cmd.none )

        AddApprove ->
            ( model, Cmd.none )

        ShowDetail approve ->
            ( model, Cmd.none )

        ApprovesReceived approves ->
            ( { model | approves = approves }, Cmd.none )


renderHeader : Html.Html Msg
renderHeader =
    div [ class "row" ]
        [ div [ class "col-md-9" ]
            [ input [] []
            ]
        , div [ class "col-md-offset-3" ]
            [ button [ onClick AddApprove ] [ Html.text "Add" ]
            ]
        ]


renderApproveList : List Approve.Model -> Html.Html Msg
renderApproveList approves =
    table [ class "table table-striped table table-hover" ]
        [ thead [] [ renderApproveHeader ]
        , tbody [] (List.map renderApproveItem approves)
        ]


renderApproveHeader : Html.Html Msg
renderApproveHeader =
    tr []
        [ th [] [ Html.text "Constituency Name" ]
        , th [] [ Html.text "Message" ]
        ]


renderApproveItem : Approve.Model -> Html.Html Msg
renderApproveItem approve =
    tr [ onClick (ShowDetail approve) ]
        [ td [] [ Html.text approve.constituency.name ]
        , td [] [ Html.text approve.message ]
        ]


decode : Decode.Decoder (List Approve.Model)
decode =
    Decode.field "approves" (Decode.list Approve.decode)


default : Model
default =
    { approves = [], year = "", voteType = "" }
