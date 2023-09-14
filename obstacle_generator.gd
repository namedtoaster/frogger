extends Node

func generate_obstacles_array(N):
	var obstacles_array = []

	# Initialize the array with zeros
	for x in range(N):
		var row = []
		for y in range(3):
			row.append(0)
		obstacles_array.append(row)

	generate_obstacles(obstacles_array, 0, N)
	return obstacles_array

func generate_obstacles(obstacles_array, row, N):
	if row >= N:
		return true

	var positions = [0, 1, 2]
	shuffle_array(positions)  # Shuffle the positions

	var num_obstacles = randi_range(0, 2)  # Generate 0 to 2 obstacles
	for i in range(num_obstacles):
		if is_path_clear(obstacles_array, row, positions[i]):
			obstacles_array[row][positions[i]] = 1

	return generate_obstacles(obstacles_array, row + 1, N)

func is_path_clear(obstacles_array, row, position):
	if row == 0:
		return true
	else:
		return obstacles_array[row - 1][position] == 0

func shuffle_array(arr):
	var n = arr.size()
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp
