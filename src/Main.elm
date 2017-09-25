import Html exposing (Html, Attribute, button, div, h1, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)

main =
  Html.beginnerProgram { model = model, view = view, update = update }

-- MODEL

type Action = Add | Minus | NoOp

type alias Piece = 
  { color : String }

type alias Tile = 
  { count : Int
  , id : Int
  , pieces: List Piece
  }

type alias Model = 
  { action : Action
  , tiles : List Tile 
  }

model : Model
model = 
  { action = NoOp
  , tiles = initTiles 25 
  }

initTiles : Int -> List Tile
initTiles n = 
  List.map (\ i -> Tile 0 i []) <| List.range 1 n

-- UPDATE

decrementTile : Int -> Tile -> Tile
decrementTile id t =
  if t.id == id then
    { t | count = t.count - 1 }
  else 
    t

incrementTile : Int -> Tile -> Tile
incrementTile id t =
  if t.id == id then
    { t | count = t.count + 1 }
  else 
    t

type Msg 
      = Increment 
      | Decrement  
      | UpdateCount Int

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      { model | 
          action = Add
      }

    Decrement ->
      { model | 
          action = Minus
      }

    UpdateCount id -> 
      if model.action == Add then
        { model |
            action = NoOp,
            tiles = List.map (incrementTile id) model.tiles 
        }
      else if model.action == Minus then
        { model |
            action = NoOp,
            tiles = List.map (decrementTile id) model.tiles 
        }
      else 
        model
        

-- Take anything as a parameter and return an Html msg
createGameTile : Tile -> Html Msg
createGameTile t = 
  div 
    [ class "tile" 
    , id <| toString t.id
    , onClick <| UpdateCount t.id
    ] 
    [ text <| toString <| t.count
    , div [ class "stack-head" ] []
    , div [ class "stack" ] []
    ]

-- VIEW

view : Model -> Html Msg
view model =
  div [ class "game" ]
    [ h1 [ class "header" ] [ text "Tak.elm" ] 
    , div 
      [ class "main" ]
      [ div 
        [ class "game-board" ]
        <| List.map createGameTile model.tiles
      ]
    , div [ class "footer" ]
      [ div 
        []
        [ button 
          [ class "action"
          , onClick Increment 
          ] 
          [ text "+" ]
        , button 
          [ class "action" 
          , onClick Decrement 
          ] 
          [ text "-" ]
        ]
      ]
    ]
