
# INT8 Quantization Simulator
# AI Neural Network Accelerator Project

# Original neural network weights
weights = [0.75, -0.50, 0.25, -1.0]

# Find the maximum absolute weight
max_value = max(abs(w) for w in weights)

# Calculate symmetric quantization scale
scale = max_value / 127

# Quantize weights into signed INT8 integers
quantized_weights = []

for w in weights:
    q = round(w / scale)

    if q < -128 or q > 127:
      print("Warning: Value outside INT8 range!")
      
    quantized_weights.append(q)

# Recover approximate floating-point values
dequantized_weights = []

for q in quantized_weights:
    original = q * scale
    dequantized_weights.append(original)

# Display results
print("Original weights:   ", weights)
print("Quantization scale: ", scale)
print("INT8 weights:       ", quantized_weights)
print("Recovered weights:  ", dequantized_weights)

# Calculate quantization errors
print("\nQuantization errors:")

for original, recovered in zip(weights, dequantized_weights):
    error = abs(original - recovered)
    print(round(error, 6))
