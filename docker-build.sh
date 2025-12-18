#!/bin/bash
# Build Docker image for Wallet Application

set -e

echo "=========================================="
echo "Building Wallet Application Docker Image"
echo "=========================================="
echo ""

# Set build variables
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
VERSION=${VERSION:-1.0.0}
IMAGE_NAME=${IMAGE_NAME:-wallet-app}
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "Build Configuration:"
echo "  Image Name: $IMAGE_NAME"
echo "  Image Tag: $IMAGE_TAG"
echo "  Version: $VERSION"
echo "  Build Date: $BUILD_DATE"
echo ""

# Build the image
echo "Building Docker image..."
docker build \
  --build-arg BUILD_DATE="$BUILD_DATE" \
  --build-arg VERSION="$VERSION" \
  -t "$IMAGE_NAME:$IMAGE_TAG" \
  -t "$IMAGE_NAME:$VERSION" \
  .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Image details:"
    docker images | grep "$IMAGE_NAME"
    echo ""
    echo "To run the application:"
    echo "  docker-compose up"
    echo ""
    echo "Or run standalone:"
    echo "  docker run -p 8080:8080 $IMAGE_NAME:$IMAGE_TAG"
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi
