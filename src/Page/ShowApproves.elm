module Page.ShowApproves exposing (Model, Msg(..), decode, default, update, view)

import Data.Approve as Approve
import Html exposing (div)
import Html.Attributes exposing (..)
import Json.Decode as Decode


type Msg
    = FetchApproves
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
        [ renderApproveList model.approves ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        FetchApproves ->
            ( model, Cmd.none )

        ApprovesReceived approves ->
            ( { model | approves = approves }, Cmd.none )


renderApproveList : List Approve.Model -> Html.Html Msg
renderApproveList approves =
    div []
        (List.map renderApproveItem approves)


renderApproveItem : Approve.Model -> Html.Html Msg
renderApproveItem approve =
    div []
        [ div [] [ Html.text approve.constituency.name ]
        , div [] [ Html.text approve.msisdn ]
        , div [] [ Html.text approve.message ]
        , div [] [ Html.text approve.region.name ]
        , div [] [ Html.text approve.agent.name ]
        ]


decode : Decode.Decoder (List Approve.Model)
decode =
    Decode.field "approves" (Decode.list Approve.decode)


default : Model
default =
    { approves = [], year = "", voteType = "" }
