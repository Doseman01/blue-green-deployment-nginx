Blue/Green Node.js Deployment with Nginx (Docker Compose)
This project demonstrates a Blue/Green deployment setup using pre-built Node.js container images behind Nginx, orchestrated with Docker Compose. It ensures zero-downtime failover through health checks, retry logic, and automated routing.
________________________________________
Project Overview
The setup implements a Blue/Green deployment strategy where:
•	Blue is the active (primary) service.
•	Green is the standby (backup) service.
•	Nginx acts as a reverse proxy that detects failures on Blue and automatically reroutes traffic to Green without causing client errors.
When Blue fails (for example, returns a 5xx error or times out), Nginx retries the request on Green within the same request flow, ensuring the user still receives a 200 OK response.
________________________________________
Features
•	Blue/Green deployment architecture
•	Automatic failover and recovery
•	Zero-downtime routing through Nginx retry policy
•	Fully parameterized environment variables through .env
•	Preserves and forwards response headers (X-App-Pool, X-Release-Id)
•	No image rebuilds required
________________________________________
Exposed Endpoints
Each Node.js service (Blue and Green) exposes the following endpoints:
Endpoint	Method	Description
/version	GET	Returns version info and headers
/healthz	GET	Reports service health
/chaos/start	POST	Simulates downtime (500 errors or timeout)
/chaos/stop	POST	Restores normal operation
________________________________________
Headers Returned
Each application includes the following headers in responses:
Header	Description
X-App-Pool	Identifies which pool handled the request (blue or green)
X-Release-Id	Shows the release version of the app instance
________________________________________
Environment Variables (.env)
Create a .env file in the project root with the following variables:
# Application images
BLUE_IMAGE=<blue_image_reference>
GREEN_IMAGE=<green_image_reference>

# Active pool (blue or green)
ACTIVE_POOL=blue

# Release identifiers
RELEASE_ID_BLUE=v1.0-blue
RELEASE_ID_GREEN=v1.0-green

# Optional port variable
PORT=8080
________________________________________
Project Structure
.
├── Dockerfile.nginx
├── README.md
├── docker-compose.yml
├── entrypoint.sh
├── nginx.conf.template
└── .env
________________________________________
Running the Project
Start the services using Docker Compose:
docker-compose up -d
Check that all containers are running:
docker ps
Access services:
•	Nginx (entrypoint): http://localhost:8080
•	Blue app: http://localhost:8081
•	Green app: http://localhost:8082
________________________________________
Testing Failover
1.	Check normal state
2.	curl -i http://localhost:8080/version
Expected headers:
X-App-Pool: blue
X-Release-Id: v1.0-blue
3.	Simulate Blue failure
4.	curl -X POST http://localhost:8081/chaos/start?mode=error
5.	Verify failover
6.	curl -i http://localhost:8080/version
Expected headers:
X-App-Pool: green
X-Release-Id: v1.0-green
7.	Restore Blue
8.	curl -X POST http://localhost:8081/chaos/stop
________________________________________
Key Nginx Configuration
Primary and backup upstreams:
upstream app_backend {
    server app_blue:8080 max_fails=2 fail_timeout=5s;
    server app_green:8080 backup;
}
Failover and retry logic:
proxy_next_upstream error timeout http_502 http_503 http_504;
proxy_next_upstream_tries 2;
Header forwarding:
proxy_pass_header X-App-Pool;
proxy_pass_header X-Release-Id;
Tight timeouts for quick failure detection:
proxy_connect_timeout 2s;
proxy_read_timeout 2s;
________________________________________
CI/CD Verification
The CI or grader will:
1.	Start all containers.
2.	Confirm Blue is active by default.
3.	Trigger /chaos/start on Blue.
4.	Verify automatic switch to Green within 10 seconds.
5.	Ensure no non-200 responses during failover.
6.	Confirm that headers are correctly forwarded by Nginx.
________________________________________
Fail Conditions
•	Any non-200 response after chaos injection.
•	Headers not matching the expected pool or release.
•	No automatic switch to Green observed after failure.
•	Instability in request responses during failover.
________________________________________
Cleanup
To stop and remove all containers:
docker-compose down
________________________________________
Learning Outcomes
By completing this project, you will learn:
•	How Blue/Green deployments ensure zero downtime.
•	How to configure Nginx for failover and retry handling.
•	How to orchestrate multi-container applications using Docker Compose.
•	How to simulate failures and verify high availability


