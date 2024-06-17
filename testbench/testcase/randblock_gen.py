import random

def generate_random_binary_string(bit_length):
    # Generate a random binary string
    return ''.join(str(random.randint(0, 1)) for _ in range(bit_length))

def binary_to_decimal(binary_str):
    # Convert binary to decimal
    return int(binary_str, 2)

def write_to_file(filename, data):
     # Write data to a file
    with open(filename, 'w') as file:
        file.write("\n".join(data))

def write_decimal_file(filename, binary_data):
    # Write decimal values to a file
    with open(filename, 'w') as file:
        for binary_str in binary_data:
            decimal = binary_to_decimal(binary_str)
            file.write(str(decimal) + "\n")  

# Create Reference Block for a 16x16 matrix
reference_block_size = 16
reference_block = [generate_random_binary_string(8) for _ in range(reference_block_size**2)]
write_to_file('ReferenceBlock_hw.txt', reference_block) # Input binary text file for hardware
write_decimal_file('ReferenceBlock_sw.txt', reference_block) # Input decimal text file for software

# Create Search Window Memory for a 31x31 matrix
search_window_size = 31
search_window_memory = [generate_random_binary_string(8) for _ in range(search_window_size**2)]
write_to_file('SearchWindowMemory_hw.txt', search_window_memory) # Input binary text file for hardware
write_decimal_file('SearchWindowMemory_sw.txt', search_window_memory)  # Input decimal text file for software

print("Files have been successfully created.")