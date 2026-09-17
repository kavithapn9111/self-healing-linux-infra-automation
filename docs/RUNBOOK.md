# Runbook

Use this runbook when the monitor reports a service or system health problem.

## Service Is Down

1. Check the monitor log.

   ```bash
   tail -n 50 logs/monitor.log
   ```

2. Check the service status.

   ```bash
   systemctl status <service-name>
   ```

3. Check recent service logs.

   ```bash
   journalctl -u <service-name> -n 100 --no-pager
   ```

4. Restart manually if needed.

   ```bash
   sudo systemctl restart <service-name>
   ```

5. Run the service monitor again.

   ```bash
   ./scripts/monitor_services.sh
   ```

## High Disk Usage

1. Check disk usage.

   ```bash
   df -h
   ```

2. Find large directories.

   ```bash
   sudo du -h /var --max-depth=1 | sort -h
   ```

3. Clean safe temporary files or rotate logs.

4. Run the system monitor again.

   ```bash
   ./scripts/monitor_system.sh
   ```

## High Memory Usage

1. Check memory usage.

   ```bash
   free -h
   ```

2. Find top memory processes.

   ```bash
   ps aux --sort=-%mem | head
   ```

3. Restart the affected service only if it is safe.

## High Load

1. Check current load and CPU usage.

   ```bash
   uptime
   top
   ```

2. Find expensive processes.

   ```bash
   ps aux --sort=-%cpu | head
   ```

3. Check whether the load is caused by CPU, disk I/O, or memory pressure.

