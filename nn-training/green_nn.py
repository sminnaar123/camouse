import torch
import numpy
import math

from PIL import Image

debug = True

# Select GPU for more performance (when cuda is available)
if (torch.cuda.is_available()):

    device = torch.device("cuda")
    if debug:
        print("Cuda device has been selected.")

else:

    device = torch.device("cpu")


# Define dataset
class CustomDataset(torch.utils.data.Dataset):
    
    def __init__(self):

        super().__init__()

        image = Image.open("./images/green/1_green.jpg")
        self.x = torch.from_numpy(numpy.array(image.getdata(), dtype=numpy.float32))

        label = Image.open("./images/green/labels/1_green_labeled.jpg")
        pixels = list(label.getdata())
        self.y = []
        for pixel in pixels:
            if (pixel[0] > 0):
                self.y.append([1])
            else:
                self.y.append([0])
        self.y = torch.from_numpy(numpy.array(self.y, dtype=numpy.float32))

    def __getitem__(self, index):

        return self.x[index], self.y[index]

    def __len__(self):

        return len(self.x)

dataset = CustomDataset()
dataloader = torch.utils.data.DataLoader(dataset, batch_size=480, shuffle=True, num_workers=12)

print(dataset[0])


# Create model
class CustomNetwork(torch.nn.Module):

    def __init__(self):

        super().__init__()
        self.input = torch.nn.Linear(3, 6)
        self.output = torch.nn.Linear(6, 1)
        self.sigmoid = torch.nn.Sigmoid()
        
    def forward(self, x):

        # Pass the input tensor through each of our operations
        x = self.input(x)
        x = self.output(x)
        x = self.sigmoid(x)
        return x

model = CustomNetwork().cuda()

# Train network
learning_rate = 0.001
epoch_amount = 1
sample_amount = len(dataset)
iteration_amount = math.ceil(sample_amount / 480)

loss = torch.nn.MSELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

for epoch in range(epoch_amount):

    for i, (inputs, labels) in enumerate(dataloader):

        # Forward pass
        prediction = model(inputs.cuda())
        
        # Determine loss
        l = loss(labels.cuda(), prediction)

        # Back propagation
        l.backward()

        # Update weight
        optimizer.step()

        # Reset gradients
        optimizer.zero_grad()

        # Debug
        if debug:
            if (i+1) % 10 == 0:
                print(f"loss = {l:.3f}")

            with torch.no_grad():
                for p, label in zip(prediction, labels):
                    if label.item() > 1:
                        print(f"predicted: {p.item():.3f}, target: {label.item():.3f}")

# Test model
with torch.no_grad():
    print(f"Prediction after training: f([0, 227, 137]) = {model(torch.tensor([0, 227, 137], dtype = torch.float32, device=device)).item():.3f}")
    print(f"Prediction after training: f([0, 0, 0]) = {model(torch.tensor([0, 0, 0], dtype = torch.float32, device=device)).item():.3f}")
    print(f"Prediction after training: f([0, 255, 0]) = {model(torch.tensor([0, 255, 0], dtype = torch.float32, device=device)).item():.3f}")