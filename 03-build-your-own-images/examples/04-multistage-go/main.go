// Simple HTTP server in Go for Docker learning
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"
)

var startTime = time.Now()

// HealthResponse represents the health check response
type HealthResponse struct {
	Status    string `json:"status"`
	Timestamp string `json:"timestamp"`
}

// InfoResponse represents the info endpoint response
type InfoResponse struct {
	AppName   string  `json:"app_name"`
	GoVersion string  `json:"go_version"`
	OS        string  `json:"os"`
	Arch      string  `json:"arch"`
	Uptime    float64 `json:"uptime_seconds"`
	Timestamp string  `json:"timestamp"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// Routes
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/info", infoHandler)

	log.Printf("🚀 Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	html := `<!DOCTYPE html>
<html>
<head>
    <title>Go Docker App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #00ADD8; }
        code {
            background: #e9ecef;
            padding: 2px 8px;
            border-radius: 4px;
        }
        .size-comparison {
            background: #d4edda;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐳 Go Docker App</h1>
        <p>This Go application demonstrates <strong>multi-stage builds</strong>.</p>
        
        <div class="size-comparison">
            <h3>Image Size Comparison</h3>
            <p>Build stage (golang:alpine): ~300MB</p>
            <p>Final image (alpine + binary): ~15MB</p>
            <p><strong>Reduction: ~95%!</strong></p>
        </div>
        
        <h2>Endpoints:</h2>
        <ul>
            <li><code>GET /</code> - This page</li>
            <li><code>GET /health</code> - Health check</li>
            <li><code>GET /api/info</code> - Application info</li>
        </ul>
        
        <h2>Runtime Info:</h2>
        <ul>
            <li>Go Version: %s</li>
            <li>OS/Arch: %s/%s</li>
        </ul>
    </div>
</body>
</html>`

	fmt.Fprintf(w, html, runtime.Version(), runtime.GOOS, runtime.GOARCH)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status:    "healthy",
		Timestamp: time.Now().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func infoHandler(w http.ResponseWriter, r *http.Request) {
	response := InfoResponse{
		AppName:   "Go Docker App",
		GoVersion: runtime.Version(),
		OS:        runtime.GOOS,
		Arch:      runtime.GOARCH,
		Uptime:    time.Since(startTime).Seconds(),
		Timestamp: time.Now().Format(time.RFC3339),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
