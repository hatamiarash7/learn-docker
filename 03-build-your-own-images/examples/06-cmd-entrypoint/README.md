# CMD vs ENTRYPOINT Examples

This directory contains examples demonstrating the difference between CMD and ENTRYPOINT.

## Files

- `Dockerfile.cmd` - CMD only example
- `Dockerfile.entrypoint` - ENTRYPOINT only example  
- `Dockerfile.both` - Combined CMD and ENTRYPOINT
- `Dockerfile.wrapper` - ENTRYPOINT as wrapper script
- `entrypoint.sh` - Wrapper script example

## Build All Images

```bash
docker build -f Dockerfile.cmd -t test-cmd .
docker build -f Dockerfile.entrypoint -t test-entrypoint .
docker build -f Dockerfile.both -t test-both .
docker build -f Dockerfile.wrapper -t test-wrapper .
```

## Test CMD Only

```bash
# Uses default CMD
docker run test-cmd
# Output: Hello from CMD!

# Override CMD completely
docker run test-cmd echo "My custom message"
# Output: My custom message

# Override with different command
docker run test-cmd ls -la
# Output: directory listing
```

## Test ENTRYPOINT Only

```bash
# ENTRYPOINT runs with no args
docker run test-entrypoint
# Output: (empty line - echo with no args)

# Arguments are appended to ENTRYPOINT
docker run test-entrypoint "Hello there!"
# Output: Hello there!

# Multiple arguments
docker run test-entrypoint "Line 1" "Line 2"
# Output: Line 1 Line 2
```

## Test Both Combined

```bash
# Uses ENTRYPOINT + default CMD
docker run test-both
# Output: Default message from CMD

# Override only CMD (ENTRYPOINT remains)
docker run test-both "Custom message"
# Output: Custom message

# Override ENTRYPOINT (use --entrypoint flag)
docker run --entrypoint ls test-both -la
# Output: directory listing
```

## Test Wrapper Script

```bash
# Run with default command
docker run test-wrapper
# Output: shows environment info then runs default CMD

# Run with custom command
docker run test-wrapper nginx -v
# Output: shows environment info then nginx version
```

## Comparison Summary

| Image           | Default Run          | With "Hello" Arg   |
| --------------- | -------------------- | ------------------ |
| test-cmd        | `Hello from CMD!`    | Runs: `echo Hello` |
| test-entrypoint | (empty)              | Runs: `echo Hello` |
| test-both       | `Default message...` | Runs: `echo Hello` |
| test-wrapper    | Env info + default   | Env info + `Hello` |

## When to Use What?

| Scenario                                          | Use                       |
| ------------------------------------------------- | ------------------------- |
| Container runs one specific command               | ENTRYPOINT                |
| Container has default behavior but is flexible    | CMD                       |
| Container is like an executable with default args | Both                      |
| Need initialization before main command           | ENTRYPOINT wrapper script |

## Cleanup

```bash
docker rmi test-cmd test-entrypoint test-both test-wrapper
```
