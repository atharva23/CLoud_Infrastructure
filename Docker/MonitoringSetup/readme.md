
```markdown
# Prometheus and Node Exporter with Docker Compose

This repository contains a Docker Compose setup to run Prometheus and Node Exporter, allowing you to monitor and collect metrics from your system.

## Prerequisites

Before running the Docker Compose setup, make sure you have the following installed:

- Docker: https://docs.docker.com/get-docker/
- Docker Compose: https://docs.docker.com/compose/install/

## Getting Started

1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/atharva23/CLoud_Infrastructure.git
   cd CLoud_Infrastructure
   ```


2. Update the `prometheus.yml` configuration file:

   Edit the `prometheus.yml` file to customize any specific configurations or targets you want to scrape. By default, it's configured to scrape metrics from the Node Exporter.

3. Start the services:

   Run the following command to start Prometheus and Node Exporter containers:

   ```bash
   docker-compose up -d
   ```

   This will start the containers in detached mode.

4. Access Prometheus Web Interface:

   Open your web browser and go to http://localhost:9090 to access the Prometheus web interface. Here, you can explore metrics and build queries to monitor your Node Exporter metrics.

5. Access Node Exporter Metrics:

   Node Exporter metrics are available at http://localhost:9100/metrics.

## Stopping the Services

To stop the running containers, use the following command:

```bash
docker-compose down
```

## Customization

Feel free to modify the `docker-compose.yml` file and the `prometheus.yml` configuration to suit your specific needs. You can add more services or modify the Prometheus scrape configurations as required.

## Contributing

If you find any issues with this project or have improvements to suggest, please feel free to open an issue or create a pull request. Your contributions are always welcome!

## License

This project is licensed under the [MIT License](LICENSE).

