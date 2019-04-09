import "dart:html";
import "dart:math";
import "package:pathfinding_dart/pathfinding_grid.dart";
import "package:tweenengine/tweenengine.dart";


class PathFinderShowcase{
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  int cellWidth, cellHeight;
  NavigationGrid navGrid;
  TweenManager tweenManager = new TweenManager();
  Position pos, start, end;

  
  GridPathFinder<NavigationGridNode> finder;
  List<NavigationGridNode> path;

  PathFinderShowcase(this.canvas,[this.finder] ){
    this.ctx = canvas.getContext("2d");
    cellWidth = canvas.width ~/ navCells[0].length;
    cellHeight = canvas.height ~/ navCells.length;
    navGrid = getGridCellMap();
    start = new Position(x: 2, y: 8);
    end = new Position(x: 4, y: 1);
    pos = new Position(x: 2.0, y: 8.0);
    path = finder.findPathCoords(2, 8, 4, 1, navGrid);
    var timeline = new Timeline.sequence();

    path.forEach((node){
      timeline
        ..push(
          new Tween.to(pos, 0, 0.5)..targetValues = [node.x, node.y]
        )
        ..pushPause(0.5);
    });
    
    timeline.repeat(Tween.infinity, 1.0);
    timeline.start(tweenManager);
  }
  
  List<List<int>> navCells = [    // 0 means closed, 1 means open, 2 is marker for start, 3 is marker for goal
    [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],	//0
    [ 0, 0, 0, 0, 3, 1, 0, 0, 0, 0 ],
    [ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0 ],
    [ 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 ],
    [ 0, 0, 0, 1, 1, 0, 1, 1, 0, 0 ], //4
    [ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0 ],
    [ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0 ],
    [ 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 ],
    [ 0, 0, 2, 1, 1, 0, 0, 0, 0, 0 ]  //8
    //0				       5           9
  ];

  NavigationGrid getGridCellMap(){
    List<List<NavigationGridNode>> cells = new List.generate(navCells[0].length, (x){
      return new List.generate(navCells.length, (y){
        var cell = new NavigationGridNode(x, y);
        cell.isWalkable = navCells[y][x] > 0;
        return cell;
      });
    });

    return new NavigationGrid(cells);
  }

  void run() async {
    while (true){
      tick( await window.animationFrame);
    }
  }

  num lastUpdate = 0;
  void tick(num delta) {
    num deltaTime = (delta - lastUpdate) / 1000;
    lastUpdate = delta;
    
    
    tweenManager.update(deltaTime);
    clearScreen();
    drawGrid();
    drawPath();
    drawPosition();
  }

  void clearScreen(){
    ctx
      ..fillStyle = "white"
      ..fillRect(0, 0, canvas.width, canvas.height);
  }

  void drawGrid(){
    int width = canvas.width ~/ cellWidth;
    int height = canvas.height ~/ cellHeight;
    
    for (num x = 0; x < width; x++){
      for (num y = 0; y < height; y++){
        String color;
        
        if (x == start.x && y == start.y){
          color =  "orange";
        }else if (x == end.x && y == end.y){
          color = "green";
        }else{
          var val = navGrid.isWalkableAt(x, y);
          if (val){
            color = "white";
          }else{
            color = "gray";
          }
        }
       
        drawCell(new Point(x, y), color);
      }
    }
  }

  void drawPath(){
    ctx.beginPath();
    double startx = start.x + 0.5;
    double starty = start.y + 0.5;

    ctx.moveTo(startx * cellWidth, starty * cellHeight);
    
    for (int i = 0; i < path.length; i++){
      var node = path[i];
      double x = node.x + 0.5;
      double y = node.y + 0.5;
      ctx.lineTo(x * cellWidth, y * cellHeight);
    }
    ctx
      ..lineWidth = 7
      ..strokeStyle = "#000080"
      ..stroke()
      ..moveTo(0, 0);
    
  }

  void drawCell(Point coords, String color) {  
    ctx
    ..fillStyle = color
    ..strokeStyle = "white";

    final int x = coords.x * cellWidth;
    final int y = coords.y * cellHeight;

    ctx
    ..fillRect(x, y, cellWidth, cellHeight)
    ..strokeRect(x, y, cellWidth, cellHeight);
    
  }

  void drawPosition(){
    num midX = (pos.x + 0.5) * cellWidth;
    num midY = (pos.y + 0.5) * cellHeight;
    
    ctx..beginPath()
      ..arc(midX, midY, cellHeight * 0.3, 0, 2 * pi, false)
      ..fillStyle = "red"
      ..fill()
      ..lineWidth = 1 
      ..strokeStyle = "#660000"
      ..stroke();

  }

}

class Position extends Tweenable{
  double x, y;

  Position({this.x = 0, this.y = 0});

  @override
  int getTweenableValues(Tween tween, int tweenType, List<num> returnValues) {
    returnValues[0] = x;
    returnValues[1] = y;
    return 2;
  }

  @override
  void setTweenableValues(Tween tween, int tweenType, List<num> newValues) {
    x = newValues[0];
    y = newValues[1];

    // print(newValues);
  }
}