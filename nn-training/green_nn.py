import torch
import numpy

from PIL import Image

# Configuration
learning_rate = 0.00001
epoch_amount = 1
batch_size = 48

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
dataloader = torch.utils.data.DataLoader(dataset, batch_size=batch_size, shuffle=True, num_workers=12)


# Create model
class CustomNetwork(torch.nn.Module):

    def __init__(self):
        super().__init__()
        self.first_hidden = torch.nn.Linear(3, 3)
        self.relu = torch.nn.ReLU()
        self.second_hidden = torch.nn.Linear(3, 1)
        
    def forward(self, x):
        # Pass the input tensor through each of our operations
        x = self.first_hidden(x)
        x = self.relu(x)
        x = self.second_hidden(x)
        return x

model = CustomNetwork().to(device)

# Train network
iteration_count = len(dataset) / batch_size
loss = torch.nn.MSELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

for epoch in range(epoch_amount):
    for i, (inputs, labels) in enumerate(dataloader):

        # Forward pass
        prediction = model(inputs.to(device))
        # Determine loss
        l = loss(labels.to(device), prediction)
        # Back propagation
        l.backward()
        # Update weight
        optimizer.step()
        # Reset gradients
        optimizer.zero_grad()
        
        if (i + 1) % batch_size == 0:
            print(f"epoch = {epoch}/{epoch_amount}, step = {i+1}/{iteration_count}, loss = {l:.5f}")

# Test model
with torch.no_grad():
    print(f"Prediction after training: f([0, 0, 0]) = {model(torch.tensor([0, 0, 0], dtype = torch.float32, device=device)).item():.5f}")
    print(f"Prediction after training: f([255, 0, 0]) = {model(torch.tensor([255, 0, 0], dtype = torch.float32, device=device)).item():.5f}")
    print(f"Prediction after training: f([0, 255, 0]) = {model(torch.tensor([0, 255, 0], dtype = torch.float32, device=device)).item():.5f}")
    print(f"Prediction after training: f([0, 0, 255]) = {model(torch.tensor([0, 0, 255], dtype = torch.float32, device=device)).item():.5f}")
    print(f"Prediction after training: f([0, 227, 137]) = {model(torch.tensor([0, 227, 137], dtype = torch.float32, device=device)).item():.5f}")
    w, b = model.first_hidden.parameters()
    print(w)