# Incident Response

This document explains how to investigate incidents detected by the self-healing monitor.

## Incident Severity

- `Low`: monitor recovered the service automatically.
- `Medium`: monitor restarted the service but the issue repeated.
- `High`: retry limit was reached and manual action is required.

## Incident Checklist

1. Confirm the alert.
2. Check `logs/monitor.log`.
3. Check the affected service with `systemctl status`.
4. Check service logs with `journalctl`.
5. Identify the most likely cause.
6. Recover the service.
7. Document what happened and how to prevent it.

## Example: Nginx Down

Signal:

```text
Unhealthy: nginx_http - Local Nginx HTTP health check
```

Investigation:

```bash
systemctl status nginx
journalctl -u nginx -n 100 --no-pager
curl -I http://localhost
```

Recovery:

```bash
sudo systemctl restart nginx
./scripts/monitor_services.sh
```

Prevention ideas:

- Validate configuration before reloads.
- Monitor port `80` and HTTP response.
- Keep enough disk space for logs.

## Simple RCA Template

```text
Incident:
Start time:
End time:
Impact:
Root cause:
Detection:
Recovery action:
What worked:
What needs improvement:
Follow-up tasks:
```

