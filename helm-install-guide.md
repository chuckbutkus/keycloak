# Installing OpenHands Theme with Bitnami Keycloak Helm Chart

This guide explains how to install the OpenHands Keycloak theme when deploying Keycloak using the Bitnami Helm chart.

## Prerequisites

- Kubernetes cluster
- Helm installed
- The `openhands-theme.jar` file (built using the `build-theme.sh` script)

## Method 1: Using initContainers to Copy the Theme

This method uses an init container to copy the theme JAR file from a ConfigMap to the Keycloak providers directory.

### Step 1: Create a ConfigMap with the Theme JAR

First, create a ConfigMap containing the theme JAR file:

```bash
kubectl create configmap openhands-theme --from-file=openhands-theme.jar=./target/openhands-theme.jar -n your-namespace
```

### Step 2: Configure the Helm Chart Values

Create a `values.yaml` file with the following content:

```yaml
extraInitContainers:
  - name: copy-theme
    image: busybox
    command:
      - sh
      - -c
      - |
        cp /themes/openhands-theme.jar /opt/bitnami/keycloak/providers/
        echo "Theme copied successfully"
    volumeMounts:
      - name: themes-volume
        mountPath: /themes
      - name: providers-volume
        mountPath: /opt/bitnami/keycloak/providers/

extraVolumes:
  - name: themes-volume
    configMap:
      name: openhands-theme
  - name: providers-volume
    emptyDir: {}

extraVolumeMounts:
  - name: providers-volume
    mountPath: /opt/bitnami/keycloak/providers/

# Configure Keycloak to use the OpenHands theme
auth:
  createAdminUser: true
  adminUser: admin
  adminPassword: adminPassword

configuration: |
  # Set OpenHands as the default theme
  KC_SPI_THEME_DEFAULT=openhands
  KC_SPI_THEME_WELCOME_THEME=openhands
  KC_SPI_THEME_ADMIN=openhands
  KC_SPI_THEME_ACCOUNT=openhands
```

### Step 3: Install or Upgrade Keycloak

Install or upgrade Keycloak with the custom values:

```bash
# For a new installation
helm install keycloak bitnami/keycloak -f values.yaml -n your-namespace

# For an upgrade
helm upgrade keycloak bitnami/keycloak -f values.yaml -n your-namespace
```

## Method 2: Using a Custom Docker Image

An alternative approach is to build a custom Docker image that includes the theme.

### Step 1: Create a Dockerfile

Create a `Dockerfile` with the following content:

```dockerfile
FROM bitnami/keycloak:latest

USER root
COPY target/openhands-theme.jar /opt/bitnami/keycloak/providers/
USER 1001
```

### Step 2: Build and Push the Docker Image

```bash
docker build -t your-registry/keycloak-openhands:latest .
docker push your-registry/keycloak-openhands:latest
```

### Step 3: Configure the Helm Chart Values

Create a `values.yaml` file with the following content:

```yaml
image:
  registry: your-registry
  repository: keycloak-openhands
  tag: latest
  pullPolicy: Always

# Configure Keycloak to use the OpenHands theme
auth:
  createAdminUser: true
  adminUser: admin
  adminPassword: adminPassword

configuration: |
  # Set OpenHands as the default theme
  KC_SPI_THEME_DEFAULT=openhands
  KC_SPI_THEME_WELCOME_THEME=openhands
  KC_SPI_THEME_ADMIN=openhands
  KC_SPI_THEME_ACCOUNT=openhands
```

### Step 4: Install or Upgrade Keycloak

```bash
# For a new installation
helm install keycloak bitnami/keycloak -f values.yaml -n your-namespace

# For an upgrade
helm upgrade keycloak bitnami/keycloak -f values.yaml -n your-namespace
```

## Method 3: Using extraStartupCommands

This method uses the `extraStartupCommands` parameter to download the theme JAR file during startup.

### Step 1: Host the Theme JAR File

Host the theme JAR file on a web server or object storage service (like S3, GCS, etc.) that's accessible from your Kubernetes cluster.

### Step 2: Configure the Helm Chart Values

Create a `values.yaml` file with the following content:

```yaml
extraStartupCommands:
  - /bin/sh
  - -c
  - |
    mkdir -p /opt/bitnami/keycloak/providers/
    curl -L -o /opt/bitnami/keycloak/providers/openhands-theme.jar https://your-storage-url/openhands-theme.jar
    echo "Theme downloaded successfully"

# Configure Keycloak to use the OpenHands theme
auth:
  createAdminUser: true
  adminUser: admin
  adminPassword: adminPassword

configuration: |
  # Set OpenHands as the default theme
  KC_SPI_THEME_DEFAULT=openhands
  KC_SPI_THEME_WELCOME_THEME=openhands
  KC_SPI_THEME_ADMIN=openhands
  KC_SPI_THEME_ACCOUNT=openhands
```

### Step 3: Install or Upgrade Keycloak

```bash
# For a new installation
helm install keycloak bitnami/keycloak -f values.yaml -n your-namespace

# For an upgrade
helm upgrade keycloak bitnami/keycloak -f values.yaml -n your-namespace
```

## Verifying the Installation

After installing Keycloak with the OpenHands theme, you can verify that the theme is working by:

1. Accessing the Keycloak admin console
2. Going to Realm Settings > Themes
3. Checking that "openhands" is available in the dropdown menus for Login Theme, Account Theme, etc.

## Troubleshooting

If the theme doesn't appear in Keycloak:

1. Check the Keycloak logs for any errors:
   ```bash
   kubectl logs -f deployment/keycloak -n your-namespace
   ```

2. Verify that the JAR file was correctly copied to the providers directory:
   ```bash
   kubectl exec -it deployment/keycloak -n your-namespace -- ls -la /opt/bitnami/keycloak/providers/
   ```

3. Restart Keycloak to ensure the theme is loaded:
   ```bash
   kubectl rollout restart deployment/keycloak -n your-namespace
   ```

4. Make sure the theme JAR file contains the correct directory structure and files.