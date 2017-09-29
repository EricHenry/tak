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
  , highlight: Bool
  , pieces: List Piece
  }

type alias Model = 
  { action : Action
  , chosenTile : Tile
  , tiles : List Tile 
  }

defaultTile : Tile
defaultTile = initTile 0 

initTile : Int -> Tile
initTile id = Tile 0 id False []

defaultPiece : Piece
defaultPiece = Piece "black"

model : Model
model = 
  { action = NoOp
  , chosenTile = defaultTile 
  , tiles = initTiles 25 
  }

initTiles : Int -> List Tile
initTiles n = 
  List.map (\ i -> Tile 0 i False []) <| List.range 1 n

-- UPDATE

decrementTile : Int -> Tile -> Tile
decrementTile id t =
  if t.id == id then
    let
      p = List.drop 1 t.pieces
    in
      { t | 
          pieces = p,
          count = List.length p
      }
  else 
    t

incrementTile : Int -> Tile -> Tile
incrementTile id t =
  if t.id == id then
    let
      p = defaultPiece :: t.pieces
    in
      { t | 
          pieces = p,
          count = List.length p
      }
  else 
    t

getChoiceDisplay : Int -> List Tile -> Tile
getChoiceDisplay id tList = 
  tList
    |> find (\t -> t.id == id) 
    |> Maybe.withDefault defaultTile
  
type Msg 
      = Increment 
      | Decrement  
      | HideTileInfo
      | ShowTileInfo Int
      | UpdateCount Int

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment       -> 
      { model | action = Add }
    Decrement       -> 
      { model | action = Minus }
    ShowTileInfo id -> 
      { model |
          chosenTile = model.tiles
            |> find (\t -> t.id == id) 
            |> Maybe.withDefault defaultTile
      }
    HideTileInfo    -> 
      { model | chosenTile = defaultTile }
    UpdateCount id  -> 
      let 
        chosenPiece = getChoiceDisplay id
      in
        case model.action of
          Add -> 
            let 
              t = List.map (incrementTile id) model.tiles
              ct = chosenPiece t
            in
              { model | 
                    action = NoOp
                  , tiles = t 
                  , chosenTile = ct
              }
          Minus -> 
            let 
              t = List.map (decrementTile id) model.tiles
              ct = chosenPiece t
            in
              { model |
                  action = NoOp
                , tiles = t
                , chosenTile = ct
              }
          NoOp ->
            { model | chosenTile = chosenPiece model.tiles } 
      
chosenPieceDisplay : Piece -> Html Msg
chosenPieceDisplay p = 
  div [ class "display-list-piece" ] []

displayChosenTile : Tile -> Html Msg
displayChosenTile {id, pieces} = 
  if id /= 0 then
    div [] <| List.map chosenPieceDisplay pieces
  else
    div [] []

highlightTileClass : Tile -> String
highlightTileClass t =
  if t.highlight then
    "highlight "
  else
    ""

-- Take anything as a parameter and return an Html msg
createGameTile : Tile -> Html Msg
createGameTile t = 
  div 
    [ t 
        |> highlightTileClass
        |> String.append "tile" 
        |> class
    , id <| toString t.id
    , onClick <| UpdateCount t.id
    ]
    [ text <| toString <| t.count
    , List.take 1 t.pieces
        |> List.map (\p -> div [ class "piece" ] [])
        |> div [ class "stack-head" ] 
    , List.tail t.pieces 
        |> Maybe.withDefault []
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
      [ List.map createGameTile model.tiles 
          |> div [ class "game-board" ] 
      , div
        [ class "main-right" ]
        [ displayChosenTile model.chosenTile ]
      ]
    , div [ class "footer" ]
      [ div 
        []
        [ button 
          [ class "action"
          , onClick Increment 
          ] 
          [ text "Add Road" ]
        , button 
          [ class "action" 
          , onClick Decrement 
          ] 
          [ text "-" ]
        , button 
            [ onClick HideTileInfo ]
            [ text "Clear Chosen Tile" ]
        ]
      ]
    ]
