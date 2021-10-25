# issue_rtdb_controller_already_firing_event

Sample that produces the following issue with Firebase Database web in Flutter.

```
@firebase/database:
Error: Bad state: Cannot fire new event. Controller is already firing an event`
```

## Getting Started

    - add firebase configuration for android `google-services.json` file with package `com.example.issue_rtdb_controller_already_firing_event`.
    - update the `web/firebase-config.js` file with your Firebase configuration.
    - add/update firebase database rules with the following:
        ```
        {
            "rules": {
                "data_logs": {
                    ".indexOn": ["isLogged"],
                    ".read": true,
                    ".write": true,
                }
            }
        }
        ```
    - Now you can run the app.