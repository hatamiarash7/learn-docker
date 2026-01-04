# Part 6 - Bonus Challenge: Smart Worker Controller


```bash
chmod +x smart-worker-controller.sh
./smart-worker-controller.sh
```
### output 
```bash
========================================
  Smart Worker Controller
========================================

Threshold: 300 seconds (5 minutes)

Container: worker-2
  App Label: cpu-worker
  Uptime: 14748 seconds
  ⚠ Uptime exceeds threshold (14748s > 300s)
  → Restarting container...
  ✓ Container restarted successfully

Container: worker-1
  App Label: cpu-worker
  Uptime: 14773 seconds
  ⚠ Uptime exceeds threshold (14773s > 300s)
  → Restarting container...
  ✓ Container restarted successfully

========================================
Summary:
  Containers restarted: 2
  Containers skipped: 0
========================================

```
