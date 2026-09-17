# Architecture

This project is a small Linux reliability automation tool.

## Components

- `monitor_loop.sh`: runs service and system checks continuously.
- `monitor_services.sh`: reads `config/services.conf` and checks each configured service.
- `self_heal.sh`: restarts unhealthy services and tracks retry attempts.
- `monitor_system.sh`: checks disk, memory, and load thresholds.
- `alert.sh`: writes alerts to logs and optionally sends email or Slack notifications.
- `common.sh`: shared logging, config loading, health checks, and retry state helpers.

## Basic Flow

```mermaid
flowchart TD
    A["monitor_loop.sh"] --> B["monitor_services.sh"]
    A --> C["monitor_system.sh"]
    B --> D{"Service healthy?"}
    D -->|"Yes"| E["Log healthy status"]
    D -->|"No"| F["self_heal.sh"]
    F --> G{"Retry limit reached?"}
    G -->|"No"| H["Restart service"]
    H --> I{"Recovered?"}
    I -->|"Yes"| J["Reset retry count"]
    I -->|"No"| K["Keep retry count"]
    G -->|"Yes"| L["alert.sh"]
    C --> M{"Threshold exceeded?"}
    M -->|"Yes"| L
    M -->|"No"| N["Log healthy status"]
```

## State And Logs

Retry state is stored in the `state/` directory by default.

Logs are stored in `logs/monitor.log` by default.

Both paths can be changed in `config/monitor.conf`.

