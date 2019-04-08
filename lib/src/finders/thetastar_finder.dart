part of pathfinding;

/**
 * A finder which will use theta star algorithm on a grid (any angle path finding).
 * It also lets you find a path based on coordinates rather than nodes on {@link NavigationGridGraph}'s.
 * 
 * @author Xavier Guzman
 *
 * @param <T> any class that inherits from {@link GridCell}
 */
class ThetaStarFinder<T extends NavigationNode> implements PathFinder<T>{

	PathFinderOptions options;
	BHeap<T> openList;
	int jobId = 0;
  int _maxJobId = 3000;
  String _finderId;
		
	ThetaStarFinder.withOptions(this.options) {
      _finderId = runtimeType.toString();
	    openList = new BHeap<T>((T o1, T o2) {
        if (o1 == null || o2 == null){
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
		
	List<T> findPath(T startNode, T endNode, NavigationGraph<T> graph) {

		validateNotNull(startNode, "Start node cannot be null");
		validateNotNull(endNode, "End node cannot be null");

		if (jobId == _maxJobId)
			jobId = 0;
		int job = ++jobId;
		
    T node, neighbor;
    List<T> neighbors = new List<T>();
    double ng;
       
    startNode.g = 0;
    startNode.f = 0;

    // push the start node into the open list
    openList.clear();
    openList.add(startNode);
    startNode.parent = null;
    startNode.setOpenedOnJob( job, _finderId );
	    
	    while (openList.size > 0) {
	    	
	        // pop the position of node which has the minimum 'f' value.
	        node = openList.pop();
	        node.setClosedOnJob(job, _finderId);
	        

	        // if reached the end position, construct the path and return it
	        if (node == endNode) {
	            return backTrace(endNode);
	        }

	        // get neighbors of the current node
	        neighbors.clear();
	        neighbors.addAll( graph.getNeighbors(node, opt: options)) ;
	        for (int i = 0, l = neighbors.length; i < l; ++i) {
	            neighbor = neighbors[i];

	            if (neighbor.getClosedOnJob(_finderId) == job || !graph.isWalkable(neighbor)) {
	                continue;
	            }
	            
	            T parent;
	            
	            if( graph.lineOfSight( node.parent, neighbor )){
	            	// get the distance between parent node and the neighbor and calculate the next g score
	            	ng = node.parent.g + graph.getMovementCost(node.parent, neighbor, options);
	            	parent = node.parent;
	            }else{
	            	// get the distance between current node and the neighbor and calculate the next g score
		            ng = node.g + graph.getMovementCost(node, neighbor, options);
		            parent = node;
	            }

	            // check if the neighbor has not been inspected yet, or can be reached with smaller cost from the current node
	            if (neighbor.getOpenedOnJob(_finderId) != job || ng < neighbor.g) {
	            	double prevf = neighbor.f;
                neighbor
                  ..g = ng
                  ..h = options.heuristic.calculate(neighbor, endNode)
                  ..f = neighbor.g + neighbor.h
                  ..parent = parent;

	                if (neighbor.getOpenedOnJob(_finderId) != job) {
	                    openList.add(neighbor);
	                    neighbor.setOpenedOnJob(job, _finderId);
	                } else {
	                    // the neighbor can be reached with smaller cost.
	                    // Since its f value has been updated, we have to update its position in the open list
	                    openList.updateNode(neighbor, neighbor.f - prevf);
	                }
	            }
	        } 
	    } 

	    // fail to find the path
	    return null;
	}
}