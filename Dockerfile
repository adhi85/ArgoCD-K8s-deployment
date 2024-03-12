# Use an official lightweight Node.js image as a base image
FROM node:alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install any dependencies
RUN npm install

# Copy all files from the current directory to the working directory
COPY . .

# Expose port 8080
EXPOSE 8080

# Command to run your application
CMD ["npm", "start"]
