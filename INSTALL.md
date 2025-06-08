# OpenHands Keycloak Theme

This repository contains a custom Keycloak theme for the OpenHands application. The theme is designed to match the look and feel of the OpenHands React application.

## Building the Theme

To build the theme, you need to have Java and Bash installed on your system. The build script will create a JAR file containing the theme.

```bash
# Make sure you're in the repository root directory
./build-theme.sh
```

This will create a JAR file named `openhands-theme.jar` in the `target` directory.

## Installation

There are several ways to install the theme in Keycloak:

### Method 1: Deploy as a JAR (Recommended)

1. Build the theme using the instructions above.
2. Copy the generated JAR file to the `providers` directory of your Keycloak installation:

   ```bash
   cp target/openhands-theme.jar /path/to/keycloak/providers/
   ```

3. Restart Keycloak to load the new theme.

### Method 2: Copy Theme Files Directly

1. Copy the theme directory to the Keycloak themes directory:

   ```bash
   cp -r themes/src/main/resources/theme/openhands /path/to/keycloak/themes/
   ```

2. Restart Keycloak to load the new theme.

## Configuring Keycloak to Use the Theme

After installing the theme, you need to configure Keycloak to use it:

1. Log in to the Keycloak Admin Console.
2. Select the realm you want to apply the theme to.
3. Go to **Realm Settings**.
4. Click on the **Themes** tab.
5. In the **Login Theme** dropdown, select `openhands`.
6. Click **Save**.

You can also set the theme for specific clients:

1. Go to **Clients** in the left sidebar.
2. Select the client you want to configure.
3. Go to the **Settings** tab.
4. Enable **Login Theme** override.
5. Select `openhands` from the dropdown.
6. Click **Save**.

## Theme Structure

The theme follows the standard Keycloak theme structure:

```
openhands/
├── common/
│   └── theme.properties
└── login/
    ├── resources/
    │   ├── css/
    │   │   └── openhands.css
    │   ├── img/
    │   │   ├── all-hands-logo.svg
    │   │   ├── favicon.ico
    │   │   └── logo.png
    │   └── js/
    │       ├── authChecker.js
    │       └── menu-button-links.js
    ├── footer.ftl
    ├── login.ftl
    ├── register.ftl
    ├── template.ftl
    └── theme.properties
```

## Customization

If you need to customize the theme further:

1. Modify the files in the `themes/src/main/resources/theme/openhands` directory.
2. Rebuild the theme using the build script.
3. Reinstall the theme using one of the methods described above.

## Troubleshooting

If the theme doesn't appear in Keycloak after installation:

1. Make sure you've restarted Keycloak after installing the theme.
2. Check the Keycloak logs for any errors related to theme loading.
3. Verify that the JAR file is in the correct location or that the theme files are in the correct directory.
4. Clear your browser cache to ensure you're seeing the latest version of the theme.

## Development

For development and testing, you can use the Keycloak development mode, which will reload themes without requiring a restart:

```bash
/path/to/keycloak/bin/kc.[sh|bat] start-dev
```

This allows you to make changes to the theme and see them immediately without restarting Keycloak.