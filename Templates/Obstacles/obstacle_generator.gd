extends Node

func generate_obstacles_array(N):
	var obstacles_array = []

	# Initialize the array with zeros
	for y in range(N):
		var row = []
		for x in range(3):
			row.append(0)
		obstacles_array.append(row)

	generate_obstacles(obstacles_array, 0, N, 0)
	return obstacles_array

func generate_obstacles(obstacles_array, row, N, consecutive_zeros):
	if row >= N:
		return true

	var positions = [0, 1, 2]
	shuffle_array(positions)  # Shuffle the positions

	var num_obstacles = randi_range(0, 2)  # Generate 0 to 2 obstacles
	if consecutive_zeros >= 2:
		num_obstacles = randi_range(1, 2)  # Ensure at least 1 obstacle if already 2 consecutive zeros

	for i in range(num_obstacles):
		if is_path_clear(obstacles_array, row, positions[i]):
			obstacles_array[row][positions[i]] = 1
			consecutive_zeros = 0
		else:
			return generate_obstacles(obstacles_array, row, N, consecutive_zeros)

	return generate_obstacles(obstacles_array, row + 1, N, consecutive_zeros + 1)

func is_path_clear(obstacles_array, row, position):
	if row == 0:
		return true
	else:
		# Ensure a clear path by checking the row above and the adjacent positions
		var above = obstacles_array[row - 1]
		if above[position] == 1:
			return false
		if position > 0 and above[position - 1] == 1:
			return false
		if position < 2 and above[position + 1] == 1:
			return false
		return true

func shuffle_array(arr):
	var n = arr.size()
	for i in range(n - 1, 0, -1):
		var j = randi() % (i + 1)
		var temp = arr[i]
		arr[i] = arr[j]
		arr[j] = temp
