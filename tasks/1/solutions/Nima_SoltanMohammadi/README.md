# Docker Task 1 Solution

Nima Soltan Mohammadi

## What's in here

- dockerfiles/ - the 3 images (log-producer, cpu-worker, toolbox)
- scripts/ - all the bash and python scripts
- outputs/ - saved outputs from running everything

## Labels vs Names - Why labels work better

After doing this task, I realized labels are way more practical than relying on container names:

**Main reasons:**

You can filter by what the container does, not what it's called. Like if I want all workers, I just do `docker ps --filter "label=tier=worker"` instead of trying to match name patterns.

Names have to be unique but labels don't. So if I have 10 workers, they all share the same labels but need different names.

If I rename a container later, my scripts won't break because they're using labels not names.

You can combine labels too. Like `app=log-producer` AND `env=training` together. With names you can only match one thing.

**Example from the task:**

The smart worker controller script only cares about containers with `app=cpu-worker`. Doesn't matter if they're named worker-1, worker-xyz, or anything else. The label is what matters.

## Notes

- docker inspect with --format is really useful for extracting specific fields
- Python + subprocess made the age calculation script much easier than doing it in bash
- The date math for uptime checking was trickier than expected
- All containers got proper labels and everything ran fine

## What I learned

Metadata-driven automation is cleaner than hardcoding names everywhere. Makes scaling easier and scripts more maintainable.
