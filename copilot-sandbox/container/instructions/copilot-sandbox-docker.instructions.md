---
applyTo: "**/*docker*,**/*Dockerfile*,**/docker-compose*"
---

# Docker Usage in Copilot Sandbox

When running `docker` commands inside the Copilot Sandbox:

## You're talking to the HOST Docker daemon

The Docker socket `/var/run/docker.sock` is mounted from the host. This means:

### Important facts

- Containers you start are **siblings** of the sandbox, not children
- They run on the **host**, not inside the sandbox
- Network and volumes are **host-based**
- Images are pulled to **host's Docker**

### Path implications

When mounting volumes, use **host paths**, not container paths:

```bash
# ✅ CORRECT - host path
docker run -v ~/project:/app my-image

# ❌ WRONG - this path doesn't exist on host
docker run -v /opt/copilot-sandbox:/app my-image
```

### Networking

```bash
# ✅ Accessing host services
docker run --network host my-image  # Shares host network

# ✅ Container-to-container communication
docker run --name db postgres
docker run --link db my-app  # Can reach the db container
```

### Examples

**Build an image:**
```bash
# Image is built on host
docker build -t my-app:latest .
```

**Run a service:**
```bash
# Container runs on host, not in sandbox
docker run -d -p 3000:3000 my-app
```

**Execute in a container:**
```bash
# Executes in sibling container on host
docker exec -it container-name bash
```

## Accessing the sandbox from other containers

If you need another container to access files in the current working directory:

```bash
# Mount the mirrored home directory path
docker run -v $(pwd):/workspace my-image

# The path $(pwd) is the same on host and in sandbox
```

## When Docker is disabled

If `COPILOT_DISABLE_DOCKER_SOCKET=1` was set, the socket is not mounted:

```bash
$ docker ps
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

This is intentional for security in some environments.

## Summary

- Docker commands reach the **host daemon**
- Use **host paths** for volumes
- Containers are **siblings**, sharing host resources
- Network and storage are **host-based**

Always remember: the sandbox is just one of potentially many containers on the host.
