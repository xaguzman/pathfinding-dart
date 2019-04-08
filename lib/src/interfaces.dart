part of pathfinding;

abstract class NavigationNode extends BHeapNode{
	
  Map<String, int> _closedOnJob = new Map();
  Map<String, int> _openedOnJob = new Map();
  static const String _defaultFinder = "_default_";

	/// The Node from which this node is reachable
  NavigationNode parent;

  int get closedOnJob => getClosedOnJob();
  set closedOnJob(int value) => setClosedOnJob(value);
  
  int get openedOnJob => getOpenedOnJob();
  set openedOnJob(int value) => setOpenedOnJob(value);

  int getClosedOnJob([String finderId =_defaultFinder]) =>
    _closedOnJob.containsKey(finderId) ? _closedOnJob[finderId] : 0;
  
  void setClosedOnJob(int jobId, [String finderId =_defaultFinder]){
    _closedOnJob[finderId] = jobId;
  }

  int getOpenedOnJob([String finderId =_defaultFinder]) =>
   _openedOnJob.containsKey(finderId) ? _openedOnJob[finderId] : 0;

   void setOpenedOnJob(int jobId, [String finderId =_defaultFinder]){
    _openedOnJob[finderId] = jobId;
  }

	double f = 0.0;
  double g = 0.0;
	
  /// the computed value of the heuristic used to get from this point to the goal node. The
	/// heuristic is determined [PathFinderOptions] used to navigate the grid
  double h = 0.0;
	
	bool isWalkable;
}

abstract class NavigationGraph<T extends NavigationNode>{
	/// Returns a list with all the adjacent nodes for the passed node
	List<T> getNeighbors(T node, {PathFinderOptions opt });
	
	/// Determines the movement cost for moving from node1 to node2, with the given options
	double getMovementCost(T node1, T node2, PathFinderOptions opt);
	
	bool isWalkable(T node );
	
	bool lineOfSight(NavigationNode from, NavigationNode to);
}

abstract class Heuristic{
  double calculate(NavigationNode from, NavigationNode to);
}

abstract class PathFinder<T extends NavigationNode> {

	/// Finds the path from [startNode](exclusive) to [endNode](inclusive). The resulting collection should never be modified, copy the values instead.
	/// Returns The path found to traverse the graph from start to end or null, if no path was found.
	List<T> findPath(T startNode, T endNode, NavigationGraph<T> grid);
}

abstract class PathFinderOptions{
  Heuristic heuristic;
}

class PathFindingException implements Exception{
  
  String msg = "";
  PathFindingException([String this.msg]);

  String toString() => msg.isEmpty ? "PathFindingException" : "PathFindingException: $msg";
}