import random

def generate_random_binary_string(bit_length):
    # Rastgele ikili dizi oluştur
    return ''.join(str(random.randint(0, 1)) for _ in range(bit_length))

def binary_to_decimal(binary_str):
    # İkiliyi ondalığa çevir
    return int(binary_str, 2)

def write_to_file(filename, data):
    # Dosyaya yaz
    with open(filename, 'w') as file:
        file.write("\n".join(data))

def write_decimal_file(filename, binary_data):
    # Ondalık değerleri dosyaya yaz
    with open(filename, 'w') as file:
        for binary_str in binary_data:
            decimal = binary_to_decimal(binary_str)
            file.write(str(decimal) + "\n")  

# 16x16 matris için Reference Block oluşturma
reference_block_size = 16
reference_block = [generate_random_binary_string(8) for _ in range(reference_block_size**2)]
write_to_file('ReferenceBlock_hw.txt', reference_block) #input binary txt file for hardware
write_decimal_file('ReferenceBlock_sw.txt', reference_block) #input decimal txt file for software

# 31x31 matris için Search Window Memory oluşturma
search_window_size = 31
search_window_memory = [generate_random_binary_string(8) for _ in range(search_window_size**2)]
write_to_file('SearchWindowMemory_hw.txt', search_window_memory) #input binary txt file for hardware
write_decimal_file('SearchWindowMemory_sw.txt', search_window_memory)  #input decimal txt file for software

print("Dosyalar başarıyla oluşturuldu.")