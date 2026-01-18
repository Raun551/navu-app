# Use a lightweight Python base image
FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Copy dependencies first (caching layer)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the actual code
COPY main.py .

# Create a non-root user (Security Best Practice!)
# Pitfall: Running as root inside a container is a major security risk.
RUN useradd -m navu
USER navu

# Expose the port
EXPOSE 5000

# Command to run the app
CMD ["python", "main.py"]
