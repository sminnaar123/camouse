from decimal import localcontext, Decimal, ROUND_HALF_UP
import math

# green params:
#   3,  36, -24,    <-- bias
#  10,  -7,   8,
#   0,   1,  -3,
#  -9,  10,  -9,
# -70,              <-- bias
#   2, -31,  19

# red params:
#  10, -21,  56,    <-- bias
#   9,   4,  -8,
#  -2, -24, -19,
# -15,  21,   6,
# -39,              <-- bias
#  -9,  33, -56

green_params = [
    0.1057,  1.1401, -0.7345,   # bias
    0.3262, -0.2159,  0.2414,   # weights
    -0.0103,  0.0157, -0.0794,  # weights
    -0.2811,  0.2981, -0.2894,  # weights
    -2.1792,                    # bias
    0.0585, -0.9722,  0.6076,   # weights
]

red_params = [
    0.3062, -0.6659,  1.7378,   # bias
    0.2777,  0.1211, -0.2365,   # weights
    -0.0732, -0.7650, -0.6020,  # weights
    -0.4835,  0.6712,  0.1987,  # weights
    -1.2202,                    # bias
    -0.2881,  1.0420, -1.7457,  # weights
]

def convert(params):
    outputs = []
    for param in params:
        output = Decimal(param * math.pow(2.0, 5.0))
        outputs.append(int(output.to_integral_value(rounding=ROUND_HALF_UP)))
    print(outputs)

print("green params:")
convert(green_params)
print("red params:")
convert(red_params)