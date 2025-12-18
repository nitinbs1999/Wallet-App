#!/bin/bash
# Run Wallet Application with Docker Compose

set -e

ACTION=${1:-up}

echo "=========================================="
echo "Wallet Application - Docker Compose"
echo "=========================================="
echo ""

case $ACTION in
  up|start)
    echo "Starting application..."
    docker-compose up -d
    echo ""
    echo "✅ Application started!"
    echo ""
    echo "Services:"
    docker-compose ps
    echo ""
    echo "Application URL: http://localhost:8080"
    echo "API Base URL: http://localhost:8080/api/v1/wallets"
    echo ""
    echo "To view logs:"
    echo "  docker-compose logs -f wallet-app"
    echo ""
    echo "To stop:"
    echo "  ./docker-run.sh stop"
    ;;
    
  down|stop)
    echo "Stopping application..."
    docker-compose down
    echo ""
    echo "✅ Application stopped!"
    ;;
    
  restart)
    echo "Restarting application..."
    docker-compose restart
    echo ""
    echo "✅ Application restarted!"
    ;;
    
  logs)
    docker-compose logs -f
    ;;
    
  build)
    echo "Building and starting application..."
    docker-compose up -d --build
    echo ""
    echo "✅ Application built and started!"
    ;;
    
  clean)
    echo "Cleaning up (removing containers and volumes)..."
    docker-compose down -v
    echo ""
    echo "✅ Cleanup complete!"
    ;;
    
  status)
    echo "Application status:"
    docker-compose ps
    ;;
    
  *)
    echo "Usage: $0 {up|down|restart|logs|build|clean|status}"
    echo ""
    echo "Commands:"
    echo "  up/start  - Start the application"
    echo "  down/stop - Stop the application"
    echo "  restart   - Restart the application"
    echo "  logs      - View application logs"
    echo "  build     - Rebuild and start"
    echo "  clean     - Stop and remove all data"
    echo "  status    - Show container status"
    exit 1
    ;;
esac
