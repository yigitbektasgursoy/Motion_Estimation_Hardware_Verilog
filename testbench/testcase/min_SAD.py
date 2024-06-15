import numpy as np

# Dosyaları oku ve listeler oluştur
with open('ReferenceBlock_sw.txt', 'r') as file:
    reference_block_flat = [int(line.strip()) for line in file]

with open('SearchWindowMemory_sw.txt', 'r') as file:
    search_window_flat = [int(line.strip()) for line in file]

# Numpy dizileri oluştur
reference_block = np.array(reference_block_flat).reshape(16, 16)
search_window = np.array(search_window_flat).reshape(31, 31)

# SAD değerlerini tutacak dizi
sad_values = np.zeros((16, 16))

# Kaydırma işlemi ve SAD hesaplama
for i in range(16):  # Dikey kaydırma
    for j in range(16):  # Yatay kaydırma
        sad_values[i, j] = np.sum(np.abs(reference_block - search_window[i:i+16, j:j+16]))

# Minimum SAD değeri ve indeksi
min_sad = np.min(sad_values)
min_indices = np.unravel_index(np.argmin(sad_values), sad_values.shape)

print(f"Minimum SAD: {min_sad} at position: {min_indices}")

# Minimum SAD değerini hexadecimal olarak yazdır
with open('min_SAD.txt', 'w') as file:
    file.write(f"{int(min_sad):X}\n")
