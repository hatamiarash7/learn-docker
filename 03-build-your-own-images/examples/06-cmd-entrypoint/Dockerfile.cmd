# ===========================================
# CMD Only Example
# ===========================================
# CMD provides default arguments that can be
# completely overridden at runtime.
# ===========================================

FROM alpine:3.18

LABEL example="CMD only"

# CMD defines the default command to run
# This can be completely replaced when running the container
# Format: CMD ["executable", "arg1", "arg2"] (exec form - preferred)
# Or:     CMD command arg1 arg2 (shell form)

CMD ["echo", "Hello from CMD!"]
