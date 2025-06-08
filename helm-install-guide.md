# Installing OpenHands Theme with Bitnami Keycloak Helm Chart

This guide explains how to install the OpenHands Keycloak theme when deploying Keycloak using the Bitnami Helm chart.

## Prerequisites

- Kubernetes cluster
- Helm installed
- The `openhands-theme.jar` file (built using the `build-theme.sh` script)

## Important Note About JAR File Size

Kubernetes ConfigMaps have a size limit of 1MB. If your `openhands-theme.jar` file exceeds this size, Method 1 below will not work. In that case, use one of the following approaches:
- Method 2: Using a Custom Docker Image (recommended for large JAR files)
- Method 4: Using a PersistentVolume (added specifically for large JAR files)
- Method 3: Using extraStartupCommands to download the JAR from an external source

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

## Method 2: Using a Custom Docker Image (Recommended for Large JAR Files)

This approach is recommended when the `openhands-theme.jar` file exceeds the 1MB ConfigMap size limit. It involves building a custom Docker image that includes the theme, which avoids the size limitations of ConfigMaps.

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

## Method 3: Using extraStartupCommands (Alternative for Large JAR Files)

This method uses the `extraStartupCommands` parameter to download the theme JAR file during startup. It's suitable for large JAR files as it bypasses the ConfigMap size limitation by downloading the file directly from an external source.

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

## Method 4: Using a PersistentVolume for Large JAR Files

This method is specifically designed for cases where the `openhands-theme.jar` file exceeds the 1MB ConfigMap size limit. It uses a PersistentVolume to store the JAR file and makes it available to Keycloak.

### Step 1: Create a PersistentVolumeClaim

Create a file named `theme-pvc.yaml` with the following content:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: openhands-theme-pvc
  namespace: your-namespace
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi  # Adjust size as needed
```

Apply the PVC:

```bash
kubectl apply -f theme-pvc.yaml
```

### Step 2: Upload the Theme JAR to the PersistentVolume

Create a temporary pod to upload the JAR file:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: theme-uploader
  namespace: your-namespace
spec:
  containers:
  - name: uploader
    image: busybox
    command: ["sleep", "3600"]
    volumeMounts:
    - name: theme-storage
      mountPath: /data
  volumes:
  - name: theme-storage
    persistentVolumeClaim:
      claimName: openhands-theme-pvc
```

Apply the pod configuration:

```bash
kubectl apply -f theme-uploader.yaml
```

Copy the JAR file to the pod:

```bash
kubectl cp ./target/openhands-theme.jar your-namespace/theme-uploader:/data/openhands-theme.jar
```

Verify the file was copied:

```bash
kubectl exec -it theme-uploader -n your-namespace -- ls -la /data
```

Delete the uploader pod when done:

```bash
kubectl delete pod theme-uploader -n your-namespace
```

### Step 3: Configure the Helm Chart Values

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
      - name: theme-storage
        mountPath: /themes
      - name: providers-volume
        mountPath: /opt/bitnami/keycloak/providers/

extraVolumes:
  - name: theme-storage
    persistentVolumeClaim:
      claimName: openhands-theme-pvc
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

### Step 4: Install or Upgrade Keycloak

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

### Troubleshooting Large JAR Files

If you're having issues with a large JAR file:

1. Check if your JAR file exceeds the ConfigMap size limit (1MB):
   ```bash
   ls -lh ./target/openhands-theme.jar
   ```

2. If using Method 4 (PersistentVolume), verify the JAR was correctly copied to the PV:
   ```bash
   # Create a temporary pod to check the PV contents
   kubectl run pv-checker --image=busybox --rm -it --restart=Never \
     --overrides='{"spec": {"volumes": [{"name": "theme-vol", "persistentVolumeClaim": {"claimName": "openhands-theme-pvc"}}], "containers": [{"name": "pv-checker", "image": "busybox", "command": ["ls", "-la", "/data"], "volumeMounts": [{"name": "theme-vol", "mountPath": "/data"}]}]}}' \
     -n your-namespace
   ```

3. If using Method 2 (Custom Docker Image), verify the JAR is included in your custom image:
   ```bash
   # Run a temporary container from your custom image
   docker run --rm -it your-registry/keycloak-openhands:latest ls -la /opt/bitnami/keycloak/providers/
   ```

4. If using Method 3 (extraStartupCommands), check if the download URL is accessible from within the cluster and that the JAR file can be downloaded successfully.