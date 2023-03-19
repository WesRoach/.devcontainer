# .devcontainer

## Issues

### Dockerfile-with-features

Mentions:

- `Dockerfile-with-features`
- `ERROR: failed to solve: rpc error: code = Unknown desc = failed to solve with frontend dockerfile.v0: failed to create LLB definition: target stage dev_containers_target_stage could not be found`

Resolution:

- Remove any rogue `\` in the `Dockerfile`. Check `RUN` statments for trailing `\` with no next line.
- Add missing `\` to `Dockerfile`.

```bash
# Example
RUN apt-get install
    package1 \
    package2 \  # Issue is here

RUN apt-get install
    package1    # Issue is here
    package2 \
    package3
```
