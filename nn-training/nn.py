from xml.etree.ElementTree import tostring
import torch
import numpy
import glob

from PIL import Image

# Parameters for GREEN
# Bias first hidden layer:
# [0.1057,  1.1401, -0.7345]
# Weights first hidden layer:
# [0.3262, -0.2159,  0.2414]
# [-0.0103,  0.0157, -0.0794]
# [-0.2811,  0.2981, -0.2894]]
# Bias second hidden layer:
# [-2.1792]
# Weights seconds hidden layer:
# [0.0585, -0.9722,  0.6076]

# Parameters for RED
# Bias first hidden layer
# [0.3062, -0.6659,  1.7378]
# Weight first hidden layer
# tensor([[ 0.2777,  0.1211, -0.2365],
#         [-0.0732, -0.7650, -0.6020],
#         [-0.4835,  0.6712,  0.1987]], device='cuda:0', requires_grad=True)
# Bias second hidden layer
# [-1.2202]
# Weights second hidden layer
# [-0.2881,  1.0420, -1.7457]

# Colors
target_color = "red"
other_colors = [
    "black",
    "blue",
    "brown",
    "grey",
    "orange",
    "violet",
    "white",
    "yellow",
    "green"
]

# Neural net configuration
learning_rate = 0.0001
epoch_amount = 50
batch_size = 1000

# Select GPU for more performance (when cuda is available)
if (torch.cuda.is_available()):
    device = torch.device("cuda")
    print("Cuda device has been selected.")
else:
    device = torch.device("cpu")
    print("No Cuda available, cpu has been selected.")

# Define dataset
class CustomDataset(torch.utils.data.Dataset):
    
    def __init__(self):
        super().__init__()

        self.y = None
        self.x = None

        target_pixels = None
        for f in glob.iglob(f"./images/color_dataset/{target_color}/*"):
            image_data = numpy.asarray(Image.open(f).convert("RGB").getdata(), dtype=numpy.float32)
            if target_pixels is None:
                target_pixels = image_data
            else:
                target_pixels = numpy.concatenate((target_pixels, image_data))

        if target_pixels is not None:
          self.y = numpy.array([[1.0-(1e-7)]] * len(target_pixels), numpy.float32)
          self.x = target_pixels

        other_pixels = None
        for color in other_colors:
            for f in glob.iglob(f"./images/color_dataset/{color}/*"):
                image_data = numpy.asarray(Image.open(f).convert("RGB").getdata(), numpy.float32)
                if other_pixels is None:
                    other_pixels = image_data
                else:
                    other_pixels = numpy.concatenate((other_pixels, image_data))

        if other_pixels is not None:
          self.y = numpy.concatenate((self.y, numpy.array([[0.0+(1e-7)]] * len(other_pixels), dtype=numpy.float32)))
          self.x = numpy.concatenate((self.x, other_pixels))
        
    def __getitem__(self, index):
        if self.x is None or self.y is None:
          raise
        return self.x[index], self.y[index]

    def __len__(self):
        if self.x is None:
          raise Exception()
        return len(self.x)

train = CustomDataset()

trainDataloader = torch.utils.data.DataLoader(train, batch_size=batch_size, shuffle=True, num_workers=12)
testDataloader = torch.utils.data.DataLoader(train, num_workers=12)

# Create model
class CustomNetwork(torch.nn.Module):

    def __init__(self):
        super().__init__()
        self.first_hidden = torch.nn.Linear(3, 3)
        self.second_hidden = torch.nn.Linear(3, 1)
        self.sigmoid = torch.nn.Sigmoid()
        
    def forward(self, x):
        # Pass the input tensor through each of our operations
        x = self.first_hidden(x)
        x = self.second_hidden(x)
        x = self.sigmoid(x)
        return x

model = CustomNetwork().to(device)

# Train network
iteration_count = len(train) / batch_size
criterion = torch.nn.BCELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

for epoch in range(epoch_amount):
    for i, (inputs, labels) in enumerate(trainDataloader):

        # Forward pass
        prediction = model(inputs.to(device))
        # Determine loss
        l = criterion(prediction, labels.to(device))
        # Back propagation
        l.backward()
        # Update weight
        optimizer.step()
        # Reset gradients
        optimizer.zero_grad()

        with torch.no_grad():
            if (i + 1) % batch_size == 0:
                print(f"epoch = {epoch+1}/{epoch_amount}, step = {i+1}/{iteration_count:.0f}, loss = {l:.5f}")

# Test model
with torch.no_grad():

    n_samples = 0.0
    n_correct = 0.0

    for images, labels in trainDataloader:

        images = images.to(device)
        labels = labels.to(device)

        predicted = model(images)

        n_samples += labels.size(0)
        n_correct += (predicted == labels).sum().item()

    print(n_correct)
    print(f"Total accuracy = {100.0 * n_correct / n_samples :.0f}%")

    print(f"Prediction for (255, 0, 0): {model(torch.tensor([[255.0, 0.0, 0.0]]).to(device)).item()}")
    print(f"Prediction for (0, 255, 0): {model(torch.tensor([[0.0, 255.0, 0.0]]).to(device)).item()}")
    print(f"Prediction for (0, 0, 255): {model(torch.tensor([[0.0, 0.0, 255.0]]).to(device)).item()}")

    print(model.first_hidden.bias)
    print(model.first_hidden.weight)

    print(model.second_hidden.bias)
    print(model.second_hidden.weight)