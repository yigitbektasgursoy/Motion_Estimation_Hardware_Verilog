import numpy as np

# Read the files and create lists
with open('ReferenceBlock_sw.txt', 'r') as file:
    reference_block_flat = [int(line.strip()) for line in file]

with open('SearchWindowMemory_sw.txt', 'r') as file:
    search_window_flat = [int(line.strip()) for line in file]

# Create numpy arrays
reference_block = np.array(reference_block_flat).reshape(16, 16)
search_window = np.array(search_window_flat).reshape(31, 31)

# Array to hold SAD values
sad_values = np.zeros((16, 16))

# Shift operation and SAD calculation
for i in range(16):  # Vertical shift
    for j in range(16):  # Horizontal shift
        sad_values[i, j] = np.sum(np.abs(reference_block - search_window[i:i+16, j:j+16]))

# Minimum SAD value and its index
min_sad = np.min(sad_values)
min_indices = np.unravel_index(np.argmin(sad_values), sad_values.shape)

print(f"Minimum SAD: {min_sad} at position: {min_indices}")

# Write the minimum SAD value in hexadecimal format
with open('min_SAD.txt', 'w') as file:
    file.write(f"{int(min_sad):X}\n")
