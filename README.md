# Self-Healing Linux Infrastructure Automation

A simple Bash-based project that monitors Linux services and system health, tries automatic recovery, keeps logs, and sends alerts when manual action is needed.

This project is intentionally easy to understand and explain in interviews. It focuses on practical Linux/SRE basics instead of complex tooling.

## What This Project Does

- Monitors important Linux services.
- Supports `systemd`, process, port, and HTTP health checks.
- Restarts failed services automatically.
- Tracks retry attempts to avoid endless restart loops.
- Monitors disk usage, memory usage, and system load.
- Writes operational logs.
- Sends optional email or Slack alerts.
- Can run continuously using `systemd`.
- Includes runbooks and incident response notes.

## Project Structure

```text
self-healing-linux-infra-automation/
├── config/
│   ├── monitor.conf
│   └── services.conf
├── docs/
│   ├── ARCHITECTURE.md
│   ├── INCIDENT_RESPONSE.md
│   ├── RUNBOOK.md
│   └── TESTING.md
├── logs/
│   └── README.md
├── scripts/
│   ├── alert.sh
│   ├── monitor_loop.sh
│   ├── monitor_services.sh
│   ├── monitor_system.sh
│   ├── self_heal.sh
│   ├── simulate_failure.sh
│   └── lib/
│       └── common.sh
├── systemd/
│   └── self-healing-monitor.service
├── .github/workflows/
│   └── shellcheck.yml
├── .gitignore
├── Makefile
└── README.md
```

## Quick Start

Run this on a Linux machine.

```bash
git clone https://github.com/kavithapn9111/self-healing-linux-infra-automation.git
cd self-healing-linux-infra-automation
chmod +x scripts/*.sh
```

Check configured services once:

```bash
./scripts/monitor_services.sh
```

Check system resources once:

```bash
./scripts/monitor_system.sh
```

Run continuously:

```bash
INTERVAL_SECONDS=60 ./scripts/monitor_loop.sh
```

## Configure Services

Edit [config/services.conf](config/services.conf).

Format:

```text
name|check_type|check_target|restart_target|description
```

Example:

```text
ssh|systemd|ssh|ssh|SSH service
nginx_http|http|http://localhost|nginx|Nginx HTTP endpoint
```

Supported check types:

- `systemd`: checks `systemctl is-active`.
- `process`: checks if a process exists using `pgrep`.
- `port`: checks if a TCP port is listening.
- `http`: checks if an HTTP endpoint responds successfully.

## Configure Thresholds

Edit [config/monitor.conf](config/monitor.conf).

Important settings:

- `MAX_RETRIES`: maximum restart attempts before alerting.
- `INTERVAL_SECONDS`: monitor loop sleep interval.
- `DISK_THRESHOLD_PERCENT`: disk alert threshold.
- `MEMORY_THRESHOLD_PERCENT`: memory alert threshold.
- `LOAD_THRESHOLD`: system load alert threshold.
- `ALERT_EMAIL`: optional email recipient.
- `SLACK_WEBHOOK_URL`: optional Slack webhook.

## Run As A systemd Service

Copy the repo to `/opt`:

```bash
sudo cp -r . /opt/self-healing-linux-infra-automation
sudo chmod +x /opt/self-healing-linux-infra-automation/scripts/*.sh
```

Install and start the service:

```bash
sudo cp systemd/self-healing-monitor.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now self-healing-monitor
sudo systemctl status self-healing-monitor
```

View logs:

```bash
tail -f logs/monitor.log
journalctl -u self-healing-monitor -f
```

## Failure Simulation

Trigger a test alert:

```bash
./scripts/simulate_failure.sh test-alert
```

Stop a service to test recovery:

```bash
sudo ./scripts/simulate_failure.sh stop-service nginx
./scripts/monitor_services.sh
```

## Resume Bullets

- Built a Linux self-healing automation platform to monitor critical services and recover from failures automatically.
- Implemented service health checks using `systemctl`, process validation, port checks, and HTTP endpoint checks.
- Designed retry-based recovery logic to restart failed services while preventing infinite restart loops.
- Added disk, memory, and load monitoring with threshold-based alerting.
- Integrated the monitor with `systemd` for continuous background execution.
- Created operational runbooks and incident response documentation for production-style troubleshooting.

## Interview Explanation

This project solves a common production operations problem: services can fail silently and increase downtime if no one notices quickly. The automation checks service health, restarts failed services safely, records every action in logs, and escalates through alerts when automated recovery cannot fix the issue.

