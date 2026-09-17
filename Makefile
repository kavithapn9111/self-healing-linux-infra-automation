SCRIPTS := $(wildcard scripts/*.sh) $(wildcard scripts/lib/*.sh)

.PHONY: bash-check shellcheck monitor-services monitor-system run-loop test-alert

bash-check:
	bash -n $(SCRIPTS)

shellcheck:
	shellcheck $(SCRIPTS)

monitor-services:
	./scripts/monitor_services.sh

monitor-system:
	./scripts/monitor_system.sh

run-loop:
	./scripts/monitor_loop.sh

test-alert:
	./scripts/simulate_failure.sh test-alert

