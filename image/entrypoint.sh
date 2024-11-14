#!/bin/bash
set -e

./start_all.sh
./novnc_startup.sh

if [ "${ENABLE_DEBUGPY}" = "1" ]; then
    # Debug mode: Start processes with debugpy wrapper
    echo "Starting debug processes..."
    
    # Start HTTP server with debugpy
    uv run python -Xfrozen_modules=off -m debugpy --listen 0.0.0.0:5678 --wait-for-client computer_use_demo/http_server.py > /tmp/server_logs.txt 2>&1 &
    SERVER_PID=$!
    
    # Start Streamlit with debugpy
    STREAMLIT_SERVER_PORT=8501 uv run python -Xfrozen_modules=off -m debugpy --listen 0.0.0.0:5679 --wait-for-client -m streamlit run computer_use_demo/streamlit.py > /tmp/streamlit_stdout.log 2>&1 &
    STREAMLIT_PID=$!
    
    # Wait for processes to initialize
    sleep 5
    
    # Verify processes are running
    if ! kill -0 $SERVER_PID 2>/dev/null || ! kill -0 $STREAMLIT_PID 2>/dev/null; then
        echo "❌ Failed to start debug processes"
        exit 1
    fi
    
    # Function to check if a port is listening
    check_port() {
        local port=$1
        netstat -tuln | grep -q ":$port "
    }
    
    # Wait for both ports to be listening
    echo "Waiting for debugpy to initialize..."
    for i in {1..30}; do
        if check_port 5678 && check_port 5679; then
            echo "✅ Debugpy is ready on both ports"
            break
        fi
        sleep 1
        if [ $i -eq 30 ]; then
            echo "❌ Timeout waiting for debugpy to be ready"
            cat /tmp/server_logs.txt
            cat /tmp/streamlit_stdout.log
            exit 1
        fi
        echo "Still waiting for debugpy... (attempt $i/30)"
    done
    
    echo "🐛 Debug mode enabled - waiting for debugger to attach on ports: 5678 (HTTP), 5679 (Streamlit)"
else
    # Normal mode: Start processes directly
    uv run python computer_use_demo/http_server.py > /tmp/server_logs.txt 2>&1 &
    STREAMLIT_SERVER_PORT=8501 uv run python -m streamlit run computer_use_demo/streamlit.py > /tmp/streamlit_stdout.log &
fi

echo "✨ Computer Use Demo is ready!"
echo "➡️  Open http://localhost:8080 in your browser to begin"

# Keep the container running
tail -f /dev/null
