part of pathfinding_grid;

class ManhattanDistance implements Heuristic{
  
  const ManhattanDistance();

  @override
  double calculate(NavigationNode from, NavigationNode to) {
    NavigationGridNode c1 = from, c2 = to;

		return calculateFromDelta((c2.x - c1.x).abs(), (c2.y - c1.y).abs());
  }

  double calculateFromDelta(num deltaX, num deltaY){
    return (deltaX + deltaY).toDouble();
  }

}

class EuclideanDistance implements Heuristic {

  const EuclideanDistance();

	@override
	double calculate(NavigationNode from, NavigationNode to) {
		NavigationGridNode c1 = from, c2 = to;
		
		return calculateFromDelta(c2.x - c1.x, c2.y - c1.y);
	}
	
	
	double calculateFromDelta(num deltaX, num deltaY){
		return math.sqrt(deltaX * deltaX + deltaY * deltaY);
	}

}

class ChebysevDistance implements Heuristic{

  const ChebysevDistance();

	@override
	double calculate(NavigationNode from, NavigationNode to) {	
    NavigationGridNode c1 = from, c2 = to;
		return calculateFromDelta( (c2.x - c1.x).abs(), (c2.y - c1.y).abs());
	}
	
	double calculateFromDelta(int dx, int dy) {
		return math.max(dx, dy).toDouble();
	}

}