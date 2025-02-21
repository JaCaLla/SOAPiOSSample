# Official image for Node.js
FROM node:18

# Fix working directory
WORKDIR /app

# Copy necessary files
COPY package.json package-lock.json ./
RUN npm install

# Copy rest of files
COPY . .

# Expose server port
EXPOSE 8000

# Command for executing server
CMD ["node", "server.js"]