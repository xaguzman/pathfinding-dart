part of pathfinding;



List<T> backTrace<T extends NavigationNode>(T node){
  List<T> _path = new List();
  _path.add(node);
  T node1 = node;
  while (node1.parent != null && node1 != node1.parent){
			node1 = node1.parent;
			_path.insert(0, node1);
		}
		_path.removeAt(0);
		return _path;
}

void validateNotNull(NavigationNode node, String msg){
		if (node == null){
			throw new PathFindingException(msg);
		}
}

