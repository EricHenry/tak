import Html exposing (Html, Attribute, button, div, h1, text)
import Html.Attributes exposing (class, id)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
{-| Find the first element that satisfies a predicate and return
Just that element. If none match, return Nothing.
    find (\num -> num > 5) [2, 4, 6, 8] == Just 6
-}
find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first::rest ->
            if predicate first then
                Just first
            else
                find predicate rest

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
  , chosenTile : Tile
  , tiles : List Tile 
  }

defaultTile : Tile
defaultTile = Tile 0 0 []

model : Model
model = 
  { action = NoOp
  , chosenTile = Tile 0 0 []
  , tiles = initTiles 25 
  }

initTiles : Int -> List Tile
initTiles n = 
  List.map (\ i -> Tile 0 i []) <| List.range 1 n

-- UPDATE

decrementTile : Int -> Tile -> Tile
decrementTile id t =
  if t.id == id then
    { t | pieces = List.drop 1 t.pieces }
  else 
    t

incrementTile : Int -> Tile -> Tile
incrementTile id t =
  if t.id == id then
    { t | pieces = Piece "black" :: t.pieces }
  else 
    t

type Msg 
      = Increment 
      | Decrement  
      | ShowTile Int
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

    ShowTile tID -> 
    { model |
        chosenTile = model.tiles
          |> find (\t -> t.id == tID) 
          |> Maybe.withDefault defaultTile
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
        { model |
            chosenTile = model.tiles
              |> find (\t -> t.id == id) 
              |> Maybe.withDefault defaultTile
        }

displayChosenTile : Tile -> Html Msg
displayChosenTile mT = 
  if mT.id /= 0 then
   div [] [ mT |> toString |> text ]
  else
    div [] []

-- Take anything as a parameter and return an Html msg
createGameTile : Tile -> Html Msg
createGameTile t = 
  div 
    [ class "tile" 
    , id <| toString t.id
    , onClick <| UpdateCount t.id
    ]
    [
    div 
      [ class "stack-head" ] 
      [ text <| toString <| List.length t.pieces ]
    , t.pieces 
        |> List.map (\p -> div [ class "stacked-piece" ] []) 
        |> div [ class "stacked-pieces" ] 
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
      , div
        [ class "main-right" ]
        [
          displayChosenTile model.chosenTile
        ]
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
