
# MAC (Multiply-Accumulate) Simulator
# AI Neural Network Accelerator Project

inputs = [2, -3, 4, 1]
weights = [5, 2, -1, 6]

bias = 3
accumulator = bias

for i in range(4):
    product = inputs[i] * weights[i]
    accumulator += product

print("Inputs:", inputs)
print("Weights:", weights)
print("Bias:", bias)
print("MAC Output:", accumulator)
