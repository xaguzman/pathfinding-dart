part of pathfinding_grid;

/// A helper class to which lets you find a path based on coordinates rather than nodes on [NavigationGrid]'s
class AStarGridFinder<T extends NavigationGridNode> extends AStarFinder{
  
  AStarGridFinder() : this.withOptions(GridFinderOptions.Default);

  AStarGridFinder.withOptions(GridFinderOptions opt) : super.withOptions(opt);
  
  List<T> findPathCoords(int startX, int startY, int endX, int endY, NavigationGrid<T> grid){
    return findPath(grid.getCell(startX, startY), grid.getCell(endX, endY), grid);
  }
}

 /// A helper class to which lets you find a path based on coordinates rather than nodes on {@link NavigationGridGraph}'s.
class ThetaStarGridFinder<T extends NavigationGridNode> extends ThetaStarFinder<T>{
	
  ThetaStarGridFinder() : this.withOptions(GridFinderOptions.Default);

	ThetaStarGridFinder.withOptions(GridFinderOptions opt) :super.withOptions(opt);
	
	List<T> findPathCoords(int startX, int startY, int endX, int endY, NavigationGrid<T> grid) {
		return findPath(grid.getCell(startX, startY), grid.getCell(endX, endY), grid); 	    
	}
	
}

/// Optimization over A*. This will always use [EuclideanDistance], regardless of the one set in the passed [options]. 
/// This should only be used on [NavigationGrid]

class JumpPointFinder<T extends NavigationGridNode> implements PathFinder<T> {
	BHeap<T> openList;
	GridFinderOptions _options;
  String _finderId;
	int jobId = 0;
  int _maxJobId = 3000;

	Heuristic euclideanDist = new EuclideanDistance();

	JumpPointFinder(GridFinderOptions options) {
		_options = options;
    _finderId =runtimeType.toString();
		openList = new BHeap<T>((T o1, T o2) {
      if (o1 == null || o2 == null) {
        if (o1 == o2)
          return 0;
        if (o1 == null)
          return -1;
        else
          return 1;

      }
      return (o1.f - o2.f).toInt();
			});
	}

	@override
	List<T> findPath(T startNode, T endNode, NavigationGraph<T> grid) {
		validateNotNull(startNode, "Start node cannot be null");
		validateNotNull(endNode, "End node cannot be null");

		if (jobId == _maxJobId)
			jobId = 0;
		int job = ++jobId;

		T node;

		startNode.g = 0;
		startNode.f = 0;

		// push the start node into the open list
		openList.clear();
		openList.add(startNode);
		startNode.parent = null;
		startNode.setOpenedOnJob(job, _finderId);

		while (openList.size > 0) {

			// pop the position of node which has the minimum 'f' value.
			node = openList.pop();
			node.setClosedOnJob(job, _finderId);

			// if reached the end position, construct the path and return it
			if (node == endNode) {
				return backTrace(endNode);
			}

			_identifySuccesors(node,grid, job, startNode, endNode);
		}

		// fail to find the path
		return null;
	}

	///Find and return the path. The resulting collection should never be
	/// modified, copy the values instead.
	List<T> findPathCoords(int startX, int startY, int endX, int endY, NavigationGrid<T> grid) {
		return findPath(grid.getCell(startX, startY), grid.getCell(endX, endY), grid);
	}

void _identifySuccesors(T node, NavigationGrid<T> graph, int job, T start, T end) {
  List<T> neightbors = _getNeighbors(node, graph);
 
  for (T neighbor in neightbors) {

    // Try to find a node to jump to:
    T jumpPoint = _jump(neighbor, node, graph, start, end);

    if (jumpPoint == null || jumpPoint.getClosedOnJob(_finderId) == job)
      continue;

    bool isDiagonalJump = (jumpPoint.x != node.x) && (jumpPoint.y != node.y);
    if (isDiagonalJump && !_options.allowDiagonal)
      continue;

    // get the distance between current node and the neighbor and
    // calculate the next g score
    double distance = euclideanDist.calculate(jumpPoint, node);
    double ng = node.g + distance;

    if (jumpPoint.getOpenedOnJob(_finderId) != job || ng < neighbor.g) {
      double prevf = jumpPoint.f;
      jumpPoint.g = ng;
      jumpPoint.h = _options.heuristic.calculate(jumpPoint, end);
      jumpPoint.f = neighbor.g + neighbor.h;
      jumpPoint.parent = node;

      if (jumpPoint.getOpenedOnJob(this._finderId) != job) {
        openList.add(jumpPoint);
        jumpPoint.setOpenedOnJob(job, _finderId);
      } else {
        // the neighbor can be reached with smaller cost.
        // Since its f value has been updated, we have to update its
        // position in the open list
        openList.updateNode(neighbor, neighbor.f - prevf);
      }
    }
  }
}

	List<T> _getNeighbors(T node, NavigationGrid<T> grid) {
		T parent = node.parent;

		if (parent != null) {
			int px = parent.x;
			int py = parent.y;
			int x = node.x, y = node.y;

			// get the normalized direction of travel
			int dx = clamp(-1, 1, (x - px));
			int dy = clamp(-1, 1, (y - py));
			dy *= _options.isYDown ? -1 : 1;

			List<T> neighbors = new List<T>();
			bool allowDiagonal = _allowedDiagonalMovement(node, dx, dy, grid);

			// search diagonally
			if (dx != 0 && dy != 0) {
				if (grid.isWalkableAt(x, y + dy)) {
					neighbors.add(grid.getCell(x, y + dy));
				}
				if (grid.isWalkableAt(x + dx, y)) {
					neighbors.add(grid.getCell(x + dx, y));
				}
				if (grid.isWalkableAt(x, y + dy) || grid.isWalkableAt(x + dx, y)) {
					neighbors.add(grid.getCell(x + dx, y + dy));
				}
				if (!grid.isWalkableAt(x - dx, y) && grid.isWalkableAt(x, y + dy)) {
					neighbors.add(grid.getCell(x - dx, y + dy));
				}
				if (!grid.isWalkableAt(x, y - dy) && grid.isWalkableAt(x + dx, y)) {
					neighbors.add(grid.getCell(x + dx, y - dy));
				}
			} else {// search orthogonally
				if (dx == 0) {// on y
					if (grid.isWalkableAt(x, y + dy)) {
						neighbors.add(grid.getCell(x, y + dy));

						if (allowDiagonal && !grid.isWalkableAt(x + 1, y)) {
							neighbors.add(grid.getCell(x + 1, y + dy));
						}
						if (allowDiagonal && !grid.isWalkableAt(x - 1, y)) {
							neighbors.add(grid.getCell(x - 1, y + dy));
						}
					}

					// In case diagonal moves are forbidden
					if (!allowDiagonal) {
						if (grid.isWalkableAt(x + 1, y))
							neighbors.add(grid.getCell(x + 1, y));
						if (grid.isWalkableAt(x - 1, y))
							neighbors.add(grid.getCell(x - 1, y));
					}

				} else { // on x
					if (grid.isWalkableAt(x + dx, y)) {
						neighbors.add(grid.getCell(x + dx, y));

						if (allowDiagonal && !grid.isWalkableAt(x, y + 1)) {
							neighbors.add(grid.getCell(x + dx, y + 1));
						}
						if (allowDiagonal && !grid.isWalkableAt(x, y - 1)) {
							neighbors.add(grid.getCell(x + dx, y - 1));
						}
					}

					// In case diagonal moves are forbidden
					if (!allowDiagonal) {
						if (grid.isWalkableAt(x, y + 1))
							neighbors.add(grid.getCell(x, y + 1));
						if (grid.isWalkableAt(x, y - 1))
							neighbors.add(grid.getCell(x, y - 1));
					}
				}
			}
			return neighbors;
		}

		return grid.getNeighbors(node, opt:_options);
	}

	T _jump(T node, T parent, NavigationGrid<T> grid, T start, T end) {
		int x = node.x, y = node.y;
		int parentX = parent.x, parentY = parent.y;
		int dx = x - parentX;
		int dy = y - parentY;
		dy *= _options.isYDown ? -1 : 1;

		if (!grid.isWalkableAt(x, y)) {
			return null;
		}

		if (x == end.x && y == end.y) {
			return grid.getCell(x, y);
		}

		bool allowDiagonal = _allowedDiagonalMovement(node, dx, dy, grid);

		// check for forced neighbors diagonally
		if (dx != 0 && dy != 0) {
			if ((grid.isWalkableAt(x - dx, y + dy) && !grid.isWalkableAt(x - dx, y))
					|| (grid.isWalkableAt(x + dx, y - dy) && !grid.isWalkableAt(x,
							y - dy))) {
				return node;
			}

		} else {
			if (dx != 0) { // moving along x
				if (allowDiagonal) {
					if ((grid.isWalkableAt(x + dx, y + 1) && !grid.isWalkableAt(x, y + 1))
							|| (grid.isWalkableAt(x + dx, y - 1) && !grid.isWalkableAt(x, y - 1))) {
						return node;
					}
				}
			} else { // moving along y
				if (allowDiagonal) {
					if ((grid.isWalkableAt(x + 1, y + dy) && !grid.isWalkableAt(x + 1, y))
							|| (grid.isWalkableAt(x - 1, y + dy) && !grid
									.isWalkableAt(x - 1, y))) {
						return node;
					}
				}
			}
		}

		// Recursive horizontal/vertical search
		if (dx != 0 && dy != 0) {
			if (grid.isWalkableAt(x + dx, y))
				return _jump(grid.getCell(x + dx, y), node, grid, start, end);
			if (grid.isWalkableAt(x, y + dy))
				return _jump(grid.getCell(x, y + dy), node, grid, start, end);
		}

		// Attemp to keep going on a straight line
		if (grid.isWalkableAt(x + dx, y + dy)) {
			T nextJump = _jump(grid.getCell(x + dx, y + dy), node, grid, start,
					end);
			if (nextJump != null)
				return nextJump;
		}

		// if cant keep going on a straight line, try a 90 degrees turn
		if (!allowDiagonal) {
			if (dx == 0
					&& (grid.isWalkableAt(x, y + 1) || grid.isWalkableAt(x, y - 1)))
				return node;

			// diagonals are forbidden
			if (dy == 0
					&& (grid.isWalkableAt(x + 1, y) || grid.isWalkableAt(x - 1, y)))
				return node;
		}

		// couldnt find a jump point
		return null;
	}

	int clamp(int min, int max, int val) {
		if (val < min)
			return min;
		if (val > max)
			return max;
		return val;
	}

	bool _allowedDiagonalMovement(T node, int dx, int dy, NavigationGrid<T> grid) {
		if (_options.allowDiagonal) {
			if (!_options.dontCrossCorners)
				return true;

			if (dx != 0 && dy != 0)
				return true;

			if (dx == 0) {
				return (grid.isWalkableAt(node.x + 1, node.y) || grid.isWalkableAt(node.x - 1, node.y))
						&& grid.isWalkableAt(node.x, node.y + dy);
			}

			return (grid.isWalkableAt(node.x, node.y + 1) || grid.isWalkableAt(node.x, node.y - 1))
					&& grid.isWalkableAt(node.x + dx, node.y);
		}
		return false;
	}

}