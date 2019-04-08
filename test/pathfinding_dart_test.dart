import 'package:pathfinding_dart/pathfinding.dart';
import 'package:pathfinding_dart/pathfinding_grid.dart';
import 'package:test/test.dart';


List<List<int>> navCells = [    // 0 means closed, 1 means open, 2 is marker for start, 3 is marker for goal
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ],	//8
  [ 0, 0, 0, 0, 3, 1, 0, 0, 0, 0 ],
  [ 0, 0, 0, 0, 1, 1, 1, 0, 0, 0 ],
  [ 0, 0, 0, 0, 0, 1, 1, 0, 0, 0 ],
  [ 0, 0, 0, 1, 1, 0, 1, 1, 0, 0 ], //4
	[ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0 ],
  [ 0, 0, 0, 1, 1, 1, 1, 1, 0, 0 ],
	[ 0, 0, 0, 1, 1, 0, 0, 0, 0, 0 ],
	[ 0, 0, 2, 1, 1, 0, 0, 0, 0, 0 ]  //0
	//0				       5           9
];

NavigationGrid getGridCellMap(){
  List<List<NavigationGridNode>> cells = new List.generate(navCells[0].length, (x){
    return new List.generate(navCells.length, (y){
      int invY = navCells.length - 1 - y;
      var cell = new NavigationGridNode(x, y);
      cell.isWalkable = navCells[invY][x] > 0;
      return cell;
    });
  });

  return new NavigationGrid(cells);
}

NavigationGrid getAutoAssignedGridCellMap() {
    List<List<NavigationGridNode>> cells = new List.generate(navCells[0].length, (x){
    return new List.generate(navCells.length, (y){
      
      int invY = navCells.length - 1 - y;
      var cell = new NavigationGridNode();
      cell.isWalkable = navCells[invY][x] > 0;
      return cell;
    });
  });

  return new NavigationGrid(cells)..autoAssignXYToNodes();
}

void main() {
  group('AStarFinder', () {
   

   AStarGridFinder finder;
   GridFinderOptions options;

   setUpAll(() {
     options = GridFinderOptions.Default;
     finder = new AStarGridFinder.withOptions(options);
   });  

    test('Orthogonal movement', () {
      NavigationGrid grid = getGridCellMap();
      Heuristic heuristic = const ManhattanDistance();

      var start = grid.getCell(2, 0), end = grid.getCell(4,7);
      options.allowDiagonal = false;
      var path = finder.findPath(start, end, grid);
      expect(path, isNotNull, reason: "No path found from $start to $end for orthogonal movement" );

      for(int i = 1 ; i < path.length; i++){
        var current = path[i];
        var prev = path[i-1];

        var dst = heuristic.calculate(prev, current);

        expect(dst, equals(1.0), reason: "Found diagonal movement during orthogonal-only movement test");
      }

    });

    test('Diagonal movement', () {
      NavigationGrid grid = getGridCellMap();
      Heuristic heuristic = const ManhattanDistance();

      var start = grid.getCell(2, 0), end = grid.getCell(4,7);
      options.allowDiagonal = true;
      var path = finder.findPath(start, end, grid);
      expect(path, isNotNull, reason: "No path found from $start to $end for diagonal movement" );

      num diagonalCount = 0;

      for(int i = 1 ; i < path.length; i++){
        var current = path[i];
        var prev = path[i-1];

        var dst = heuristic.calculate(prev, current);
        if (dst > 1.0)        
          diagonalCount++;
      }

      expect(diagonalCount, greaterThan(0), reason: "No diagonal movement during diagonal movement test");

    });

    test('AutoAssignXY', (){
      NavigationGrid grid = getAutoAssignedGridCellMap();
		  var c = grid.getCell(3, 1);
		
		  expect(c.x, 3, reason: "GridCell at Grid(3,2) didn't have it's x auto assigned correctly");//, c.x == 3 && c.y == 1);
      expect(c.y, 1, reason: "GridCell at Grid(3,2) didn't have it's y auto assigned correctly");
		
		  var start = grid.getCell(2, 0), end = grid.getCell(4, 7);
		
		  //test orthogonal movement only
		  options.allowDiagonal = false;
		
		  var path = finder.findPath(start,  end,  grid);
      expect(path, isNotNull, reason: "No path found from $start to $end after auto assigning xy" );
      //assertNotNull(String.format("No path found from %s to %s for orthogonal movement", start, end), path);
    });

  });


  group('ThetaStarFinder', () {
   
   ThetaStarGridFinder finder;
   GridFinderOptions options;

   setUpAll(() {
     options = GridFinderOptions.Default;
     finder = new ThetaStarGridFinder.withOptions(options);
   });  

    test('Any angle movement', () {
      // restricting movement to only orthogonal makes no sense, theta star will always allow diagonal movement by nature
      NavigationGrid grid = getGridCellMap();

      var start = grid.getCell(2, 0), end = grid.getCell(4,7);
      var path = finder.findPath(start, end, grid);
      expect(path, isNotNull, reason: "No path found from $start to $end for orthogonal movement" );
    });
  });
}

