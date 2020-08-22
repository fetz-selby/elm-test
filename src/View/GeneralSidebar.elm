module View.GeneralSidebar exposing (Model, Msg(..), default, setLevel, update, view)

import Html exposing (div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


type Msg
    = Constituencies
    | Regions
    | Users
    | Agents
    | Candidates
    | Parties
    | Polls
    | ParentConstituencies
    | Approve
    | Seats
    | RegionalSummary
    | NationalSummary


type Level
    = User
    | Admin
    | SuperAdmin


type alias Model =
    { current : Msg
    , title : String
    , level : String
    }


view : Model -> Html.Html Msg
view { level } =
    let
        userLevel =
            convertToLevel level
    in
    div
        [ class "row" ]
        [ menu userLevel SuperAdmin "Regions" Regions
        , menu userLevel SuperAdmin "Users" Users
        , menu userLevel Admin "Agents" Agents
        , menu userLevel User "Constituency" Constituencies
        , menu userLevel User "Candidates" Candidates
        , menu userLevel Admin "Parties" Parties
        , menu userLevel User "Polls" Polls
        , menu userLevel SuperAdmin "Parent Constituency" ParentConstituencies
        , menu userLevel User "Approve" Approve
        , menu userLevel User "Seats" Seats
        , menu userLevel User "Regional Summary" RegionalSummary
        , menu userLevel Admin "National Summary" NationalSummary
        ]


update : Model -> Msg -> ( Model, Cmd Msg )
update model msg =
    case msg of
        Regions ->
            ( { model | current = Regions }, Cmd.none )

        Agents ->
            ( { model | current = Agents }, Cmd.none )

        Users ->
            ( { model | current = Users }, Cmd.none )

        Constituencies ->
            ( { model | current = Constituencies }, Cmd.none )

        Candidates ->
            ( { model | current = Candidates }, Cmd.none )

        Parties ->
            ( { model | current = Parties }, Cmd.none )

        Polls ->
            ( { model | current = Polls }, Cmd.none )

        ParentConstituencies ->
            ( { model | current = ParentConstituencies }, Cmd.none )

        Approve ->
            ( { model | current = Approve }, Cmd.none )

        Seats ->
            ( { model | current = Seats }, Cmd.none )

        RegionalSummary ->
            ( { model | current = RegionalSummary }, Cmd.none )

        NationalSummary ->
            ( { model | current = NationalSummary }, Cmd.none )


menu : Level -> Level -> String -> Msg -> Html.Html Msg
menu level requiredLevel label event =
    case level of
        User ->
            case requiredLevel of
                User ->
                    renderMenu label event

                Admin ->
                    div [] []

                SuperAdmin ->
                    div [] []

        Admin ->
            case requiredLevel of
                User ->
                    renderMenu label event

                Admin ->
                    renderMenu label event

                SuperAdmin ->
                    div [] []

        SuperAdmin ->
            renderMenu label event


renderMenu : String -> Msg -> Html.Html Msg
renderMenu label msg =
    div
        [ class "col-md-12 sidebar-menu", onClick msg ]
        [ text label
        ]


convertToLevel : String -> Level
convertToLevel level =
    case level |> String.toUpper of
        "U" ->
            User

        "A" ->
            Admin

        "S" ->
            SuperAdmin

        _ ->
            User


default : Model
default =
    { current = Regions, title = "", level = "U" }


setLevel : String -> Model -> Model
setLevel level model =
    { model | level = level }
