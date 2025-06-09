# OpenHands Keycloak Theme

This is a custom Keycloak theme for the OpenHands application. The theme is designed to match the look and feel of the OpenHands React application.

## Features

- Dark theme with yellow accents matching the OpenHands color scheme
- Custom login and registration pages
- Responsive design
- OpenHands branding and logo

## Structure

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

## Installation

See the main INSTALL.md file in the repository root for installation instructions.

## Customization

The theme can be customized by modifying the CSS and FreeMarker template files. The main styling is defined in `login/resources/css/openhands.css`.

## Credits

- OpenHands Project: [https://github.com/All-Hands-AI/OpenHands](https://github.com/All-Hands-AI/OpenHands)
- Keycloak: [https://www.keycloak.org/](https://www.keycloak.org/)