part of pathfinding_grid;

/// A [NavigationGraph] which is presented as a grid or table.
/// The nodes are accesible through [x,y]
class NavigationGrid<T extends NavigationGridNode> extends NavigationGraph<T>{
	
  List<List<T>> _nodes;
  List<T> _neighbors = new List();
  int width;
  int height;

	T getCell(int x, int y) => this.contains(x, y) ? this.nodes[x][y] : null;
	void setCell(int x, int y, T node){
    if ( this.contains(x, y) )
			nodes[x][y] = node;
  }

  List<List<T>> get nodes => _nodes;
  set nodes(List<List<T>> value){
    _nodes = value;
    if (nodes != null){
      this.width = nodes.length;
      this.height = nodes[0].length;
    }else{
      this.width = 0;
      this.height = 0;
    }
  }

  /// The grid will automatically assign x, y values, under the assumption that nodes[0][0] is the lower left corner of the grid. 
	///
	///   -----------------------
	///  |  0,2	|       |  2,2  |
	///   -----------------------
	///  |      |       |       |
	///  -----------------------
	/// |  0,0	|       |  2,0  |
	///  -----------------------
	/// 
	/// @param nodes the nodes which compose the graph. Can be null if you plan to set the nodes later
	///  @param autoAssignXY wetherTo automatically assign coordinates to your nodes 
  void autoAssignXYToNodes() {
    if (nodes != null){
      for(int x = 0; x < width; x++){
        for(int y = 0; y < height; y++){
          nodes[x][y]
            ..x = x
            ..y = y;
        }
      }
    }
  }

	/// Determine wether the given x,y pair is within the bounds of this grid
  /// 
	/// [x] - The x / column coordinate of the node.
	/// [y] - The y / row coordinate of the node.
	/// Returns true if the [x,y] is within the boundaries of this grid
	bool contains(int x, int y) {
    return (x >= 0 && x < this.width) && (y >= 0 && y < this.height);
  }


	/// Set whether the node on the given position is walkable.
  /// 
	/// [x] - The x / column coordinate of the node.
	/// [y] - The y / row coordinate of the node.
	/// [walkable] - Whether the position is walkable.
	/// Throws error if the coordinate is not inside the grid.
	void setWalkable(int x, int y, bool walkable) => this.nodes[x][y].isWalkable = walkable;
	
  @override
  List<T> getNeighbors(T node, {PathFinderOptions opt}) {
    GridFinderOptions options = opt ?? GridFinderOptions.Default;
    bool allowDiagonal = options.allowDiagonal;
    bool dontCrossCorners = options.dontCrossCorners;
    int yDir = options.isYDown ? -1 : 1;
    int x = node.x, y = node.y;
    _neighbors.clear();

    bool  s0 = false, d0 = false, s1 = false, d1 = false,
        	s2 = false, d2 = false, s3 = false, d3 = false;

    // up
	    if (isWalkableAt(x, y + yDir)) {
	        _neighbors.add(nodes[x][y  + yDir]);
	        s0 = true;
	    }
	    // right
	    if (isWalkableAt(x+1, y)) {
	        _neighbors.add(nodes[x + 1][y]);
	        s1 = true;
	    }
	    // down
	    if (isWalkableAt(x, y - yDir)) {
	        _neighbors.add(nodes[x][y - yDir]);
	        s2 = true;
	    }
	    // left
	    if (isWalkableAt(x - 1, y)) {
	        _neighbors.add(nodes[x - 1][y]);
	        s3 = true;
	    }
	    
	    if (!allowDiagonal) {
	        return _neighbors;
	    }

	    if (dontCrossCorners) {
	        d0 = s3 && s0;
	        d1 = s0 && s1;
	        d2 = s1 && s2;
	        d3 = s2 && s3;
	    } else {
	        d0 = s3 || s0;
	        d1 = s0 || s1;
	        d2 = s1 || s2;
	        d3 = s2 || s3;
	    }

	    // up left
	    if (d0 && this.isWalkableAt(x - 1, y + yDir)) {
	        _neighbors.add(nodes[x-1][y + yDir]);
	    }
	    // up right
	    if (d1 && this.isWalkableAt(x + 1, y + yDir)) {
	        _neighbors.add(nodes[x + 1][y + yDir]);
	    }
	    // down right
	    if (d2 && this.isWalkableAt(x + 1, y - yDir)) {
	        _neighbors.add(nodes[x + 1][y - yDir]);
	    }
	    // down left
	    if (d3 && this.isWalkableAt(x - 1, y - yDir)) {
	        _neighbors.add(nodes[x - 1][y - yDir]);
	    }

	    return _neighbors;
  }
 
  @override
  bool isWalkable(T node) => isWalkableAt(node.x, node.y);
	
	/// Determine whether the node at the given position is walkable.
	///
	/// [x] - The x / column coordinate of the node.
	/// [y] - The y / row coordinate of the node.
	/// Returns true if the node at [x,y] is walkable, false if it is not walkable (or if [x,y] is not within the grid's limit)
	bool isWalkableAt(int x, int y) => this.contains(x, y) && this.nodes[x][y].isWalkable;

  @override
  double getMovementCost(T node1, T node2, PathFinderOptions opt) {
    if (node1 == node2)
			return 0;
		
		GridFinderOptions options = opt as GridFinderOptions;
		return node1.x == node2.x || node1.y == node2.y  ? 
				options.orthogonalMovementCost : options.diagonalMovementCost;
  }
	
  NavigationGrid(List<List<T>> navnodes){
    nodes = navnodes;
  }

  @override
  bool lineOfSight(NavigationNode from, NavigationNode to) {
    if (from == null || to == null)
			return false;
		
		NavigationGridNode node = from, neigh = to;
		int x1 = node.x, y1 = node.y;
		int x2 = neigh.x, y2 = neigh.y;
		int dx = (x1 - x2).abs();
		int dy = (y1 - y2).abs();
		int xinc = (x1 < x2) ? 1 : -1;
		int yinc = (y1 < y2) ? 1 : -1;
		
		int error = dx - dy;
		
		for ( int n = dx + dy; n > 0; n--){
			if (!isWalkableAt(x1, y1)) 
				return false; 
			int e2 = 2*error;
			if ( e2 > -dy){
				error -= dy;
				x1 += xinc;
			}		
			if (e2 < dx ){
				error += dx;
				y1 += yinc;
			}
		}
		
		return true;
  }
}


class GridFinderOptions extends PathFinderOptions {

  static final GridFinderOptions Default = new GridFinderOptions();

  @override
  Heuristic heuristic;

  /// 
	/// Wether diagonal movement is allowed within the grid.
	///
	/// Note: This will be ignored in {@link JumpPointFinder}, as diagonal movement is required for it
	bool allowDiagonal;
	
	/// When true, diagonal movement requires both neighbors to be open.
	/// When false, diagonal movement can be achieved by having only one open nighbor

	/// Example: To go from (1,1) to (2,2) when this is set to true, where (x) denotes a non walkable cell,
	/// the following applies

	///                 Valid           Invalid

	///             +---+---+---+    +---+---+---+
	///             |   |   | 0 |    |   | x | 0 |
	///             +---+---+---+    +---+---+---+
	/// when True   |   | 0 |   |    |   | 0 |   |
	///             +---+---+---+    +---+---+---+
	///             |   |   |   |    |   |   |   |
	///             +---+---+---+    +---+---+---+

	///  
	///             
	///             +---+---+---+    
	///             |   | x | 0 |    
	///             +---+---+---+    
	/// when false  |   | 0 |   |    none
	///             +---+---+---+    
	///             |   |   |   |    
	///             +---+---+---+    

	/// If [allowDiagonal] is false, this setting is ignored.
	/// Default value is true

	bool dontCrossCorners;
	

	/// When false, (0,0) is located at the bottom left of the grid. When true, (0,0) is located
	/// at the top left of the grid
	///
	/// Default value is true
	bool isYDown ;
	
	/// The cost of moving one cell over the x or y axis
	double orthogonalMovementCost;
	
	// The cost of moving one cell over both the x and y axis
	double diagonalMovementCost;
	
	GridFinderOptions( {
    this.allowDiagonal = true, 
    this.dontCrossCorners = true, 
    this.heuristic = const ManhattanDistance(), 
    this.isYDown = true, 
    this.orthogonalMovementCost = 1.0, 
    this.diagonalMovementCost = 1.4
    });
}