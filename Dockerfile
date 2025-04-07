# Use official Node.js image from Docker Hub
FROM node:16

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies inside the container
RUN npm install

# Copy the rest of the application files to the container
COPY . .

# Expose the port the app runs on (3000 in this case)
EXPOSE 3000

# Define the command to run the application
CMD ["npm", "start"]
