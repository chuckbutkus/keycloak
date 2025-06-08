#!/bin/bash

# Build script for OpenHands Keycloak theme
# This script creates a JAR file containing the OpenHands theme for Keycloak

set -e

# Configuration
THEME_NAME="openhands"
OUTPUT_DIR="target"
JAR_NAME="openhands-theme.jar"

# Create output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

echo "Building OpenHands Keycloak theme..."

# Create a temporary directory for building the JAR
WORK_DIR="./build-tmp"
rm -rf $WORK_DIR
mkdir -p $WORK_DIR/theme/$THEME_NAME

# Copy the theme files to the temporary directory
cp -r themes/src/main/resources/theme/$THEME_NAME/* $WORK_DIR/theme/$THEME_NAME/

# Create META-INF directory and add theme.properties
mkdir -p $WORK_DIR/META-INF
cat > $WORK_DIR/META-INF/keycloak-themes.json << EOF
{
    "themes": [{
        "name" : "openhands",
        "types": [ "login", "account", "admin" ]
    }]
}
EOF

# Create the JAR file
echo "Creating JAR file: $OUTPUT_DIR/$JAR_NAME"
cd $WORK_DIR
jar cf ../$OUTPUT_DIR/$JAR_NAME *
cd ..

# Clean up
rm -rf $WORK_DIR

echo "Build completed successfully!"
echo "JAR file created at: $OUTPUT_DIR/$JAR_NAME"