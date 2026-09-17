# Testing

Use these commands to test the project.

## Syntax Check

```bash
make bash-check
```

Or without `make`:

```bash
bash -n scripts/*.sh scripts/lib/*.sh
```

## ShellCheck

```bash
make shellcheck
```

## Test Alert Logging

```bash
./scripts/simulate_failure.sh test-alert
tail -n 20 logs/monitor.log
```

## Test System Checks

```bash
./scripts/monitor_system.sh
```

## Test Service Checks

Edit `config/services.conf` so it matches your machine.

Then run:

```bash
./scripts/monitor_services.sh
```

## Test Self-Healing

Example with Nginx:

```bash
sudo systemctl stop nginx
./scripts/monitor_services.sh
systemctl status nginx
```

Expected result:

- The script detects the failed HTTP check.
- It attempts to restart `nginx`.
- It logs the recovery attempt.
- If recovery succeeds, it resets the retry count.
- If recovery fails too many times, it sends an alert.

