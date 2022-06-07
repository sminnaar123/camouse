import torch
import numpy

from PIL import Image

# Configuration
learning_rate = 0.00001
epoch_amount = 1000
batch_size = 480

# Select GPU for more performance (when cuda is available)
if (torch.cuda.is_available()):
    device = torch.device("cuda")
    print("Cuda device has been selected.")
else:
    device = torch.device("cpu")
    print("No Cuda available, cpu has been selected.")

# Define dataset
class CustomDataset(torch.utils.data.Dataset):
    
    def __init__(self, train=True):
        super().__init__()
        self.image_pixels = None
        self.label_pixels = None

        if train:
            self.image_locations = ["./images/green/1_green.jpg", "./images/green/2_green.jpg"]
            self.label_locations = ["./images/green/1_green_labeled.jpg", "./images/green/2_green_labeled.jpg"]

            # EXTRA GREEN IMAGE DATASET
            # self.green_image_locs = [
            #     "./images/green/14_green.jpg",
            #     "./images/green/17_green.jpg",
            #     "./images/green/18_green.jpg",
            #     "./images/green/19_green.jpg",
            #     "./images/green/25_green.jpg"
            # ]

            # # Import green images (where all pixels should be 1)
            # for green_image_loc in self.green_image_locs:
            #     green_image = Image.open(green_image_loc)
            #     resized_green_image = green_image.resize((640, 480), Image.Resampling.LANCZOS)
            #     green_image_data = numpy.array(resized_green_image.getdata(), dtype=numpy.float32)
            #     if self.image_pixels is None:
            #         self.image_pixels = green_image_data
            #     else:
            #         self.image_pixels = numpy.concatenate((self.image_pixels, green_image_data))

            # self.green_label_pixels = numpy.array([[1.0-(1e-7)] * 1] * len(self.image_pixels), dtype=numpy.float32)
        else:
            self.image_locations = ["./images/green/2_green.jpg"]
            self.label_locations = ["./images/green/2_green_labeled.jpg"]

        # Load input images
        for image_location in self.image_locations:
            image = Image.open(image_location)
            image_data = numpy.array(image.getdata(), dtype=numpy.float32)
            if self.image_pixels is None:
                self.image_pixels = image_data
            else:
                self.image_pixels = numpy.concatenate((self.image_pixels, image_data))

        # Load labels for images
        for label_location in self.label_locations:
            label = Image.open(label_location)
            label_data = numpy.array(label.getdata(), dtype=numpy.float32)
            if self.label_pixels is None:
                self.label_pixels = label_data
            else:
                self.label_pixels = numpy.concatenate((self.label_pixels, label_data))

        # Convert image pixel array to tensor
        self.x = torch.from_numpy(numpy.array(self.image_pixels, dtype=numpy.float32))

        # Convert labels to a 1 or 0 (white and black respectively)
        self.y = []
        for pixel in self.label_pixels:
            if (pixel[0] > 0):
                self.y.append([1.0-(1e-7)])
            else:
                self.y.append([0.0+(1e-7)])
        self.y = torch.from_numpy(numpy.array(self.y, dtype=numpy.float32))

    def __getitem__(self, index):
        return self.x[index], self.y[index]

    def __len__(self):
        return len(self.x)

train = CustomDataset()
test = CustomDataset(train=False)

trainDataloader = torch.utils.data.DataLoader(train, batch_size=batch_size, shuffle=True, num_workers=12)
testDataloader = torch.utils.data.DataLoader(test, batch_size=batch_size, num_workers=12)

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
loss = torch.nn.BCELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)

for epoch in range(epoch_amount):
    for i, (inputs, labels) in enumerate(trainDataloader):

        # Reset gradients
        optimizer.zero_grad()
        # Forward pass
        prediction = model(inputs.to(device))
        # Determine loss
        l = loss(labels.to(device), prediction)
        # Back propagation
        l.backward()
        # Update weight
        optimizer.step()

        with torch.no_grad():
            if (i + 1) % batch_size == 0:
                print(f"epoch = {epoch+1}/{epoch_amount}, step = {i+1}/{iteration_count:.0f}, loss = {l:.5f}")

# Test model
with torch.no_grad():

    n_samples = 0.0
    n_correct = 0.0

    for images, labels in testDataloader:

        images = images.to(device)
        labels = labels.to(device)

        predicted = model(images)

        n_samples += labels.size(0)
        n_correct += (predicted == labels).sum().item()

    print(n_correct)
    print(f"Accuracy = {100.0 * n_correct / n_samples :.0f}%")