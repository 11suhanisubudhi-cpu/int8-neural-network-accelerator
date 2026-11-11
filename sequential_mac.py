
# Sequential MAC Architecture
# One MAC unit calculates four outputs

inputs = [2, -3, 4, 1]

weights = [
    [1, 2, -1, 3],
    [2, 0, 1, -2],
    [-1, 1, 2, 1],
    [3, -1, 0, 2]
]

outputs = []

# Reuse the same MAC operation for each output neuron
for neuron in range(4):

    accumulator = 0

    for i in range(4):
        accumulator += inputs[i] * weights[neuron][i]

    outputs.append(accumulator)

print("Inputs:", inputs)
print("Output values:", outputs)
