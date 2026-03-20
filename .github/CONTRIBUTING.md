# Contributing to Home Lab

Thank you for your interest in contributing! This project is designed for personal use in home lab environments, but we welcome contributions from the community.

## How to Contribute

### 1. Bug Reports

Found an issue? Help us fix it:

1. **Check existing issues** — Search [GitHub Issues](https://github.com/yourrepo/issues) to avoid duplicates
2. **Describe the problem**:
   - What were you trying to do?
   - What happened instead?
   - What did you expect to happen?
3. **Include details**:
   - OS and Docker version: `docker --version && docker-compose --version`
   - Service name and logs: `docker compose logs -f <service_name>`
   - Configuration (remove secrets): Your `.env` file structure
   - Hardware specs (CPU cores, RAM) if performance-related

**Example issue title**: `docker compose up fails with "no space left on device" for media stack`

### 2. Feature Requests

Want a new service or enhancement?

1. **Open a discussion or issue** with the title: `[Feature] Your Idea`
2. **Describe the use case**:
   - What problem does this solve?
   - How would a user interact with it?
   - Does it fit the "lightweight, zero-config" philosophy?
3. **Reference similar projects** — Show how other tools handle this feature

**Example**: Add auto-backup to NAS using `rclone`

### 3. Documentation Improvements

Help clarify or expand the docs:

- **Fix typos or unclear instructions** — Create an issue or PR directly
- **Add guides** — How to set up reverse proxy with Cloudflare, backup to S3, etc.
- **Improve service READMEs** — Add more examples, troubleshooting tips
- **Translate documentation** — Russian, Spanish, or other languages welcome

### 4. Testing & Compatibility

Test the project on your hardware and report findings:

- **New OS**: Ubuntu 24.04, Fedora 40, Raspberry Pi OS, etc.
- **Hardware**: Low-power boards (Raspberry Pi, Orange Pi), NAS systems
- **Docker versions**: Test with older/newer Docker versions
- **Storage backends**: NAS mounts, cloud storage, USB drives

**Report results** as an issue: `[Testing] Ubuntu 24.04 on Raspberry Pi 4 — Works/Fails`

---

## Development Setup

### Prerequisites

```bash
git --version          # 2.0+
docker --version       # 19.03+
docker-compose --version  # 1.25+
bash --version         # 4.0+
```

### Clone & Test Locally

```bash
git clone https://github.com/yourusername/home-lab.git
cd home-lab

# Test a service
cd src/dashboard
docker compose up -d

# Verify it's running
docker compose ps
docker compose logs -f
```

### Making Changes

1. **Create a branch** for your feature/fix:
   ```bash
   git checkout -b feature/my-new-service
   # or
   git checkout -b fix/volume-mount-issue
   ```

2. **Make your changes** following project conventions:
   - Follow `.github/instructions/copilot.instructions.md` for Docker Compose patterns
   - Use `.env.example` for configuration templates
   - Include a `README.md` for new services
   - Add `docker-compose.volumes.yml` and `docker-compose.bind.yml` overrides

3. **Test thoroughly**:
   ```bash
   # Test your service
   cd src/your-service
   docker compose up -d
   docker compose logs -f
   
   # Verify no errors
   docker compose config  # Check syntax
   
   # Clean up
   docker compose down
   ```

4. **Commit with clear messages**:
   ```bash
   git commit -m "Add: New service X with documentation"
   # or
   git commit -m "Fix: Storage volume paths not respected in .env"
   ```

5. **Push and create a Pull Request**:
   ```bash
   git push origin feature/my-new-service
   ```

### Commit Message Guidelines

Follow conventional commits:

- `add:` — New service or feature
- `fix:` — Bug fix or correction
- `docs:` — Documentation updates
- `refactor:` — Code reorganization without behavior change
- `test:` — Testing additions or improvements

**Examples**:
```
add: Vaultwarden password manager service with storage profiles
fix: qBittorrent VPN routing not persisting on restart
docs: clarify Host volumes directory structure
```

---

## Project Conventions

### Docker Compose Files

Every service must include:

1. **`docker-compose.yml`** — Main service definition with named volumes
2. **`docker-compose.volumes.yml`** — Override file for volume path mapping (production-recommended)
3. **`docker-compose.bind.yml`** — Override file for bind mounts (advanced option)
4. **`.env.example`** — Configuration template with all available variables
5. **`README.md`** — Service documentation
6. **`prepare-volumes.sh`** — Script to create required directories (if needed)

**Why three compose files?**
- Users choose their preferred storage strategy (named volumes, bind mounts, or Docker-managed)
- Same service works in testing, development, and production
- No data migration needed when switching strategies

### README.md Structure (Per Service)

Each service README should include:

1. **Brief description** (1-2 sentences)
2. **Components** (if multi-service)
3. **Quick start** (all three storage strategies)
4. **Ports & access** (how to reach the service)
5. **Storage configuration** (volumes & data paths)
6. **Reverse proxy integration** (how to expose remotely)
7. **Configuration** (environment variables, secrets)
8. **Troubleshooting** (common issues)

See `src/media/README.md` for a complete example.

### Environment Variables

**Naming convention** for bind mount variables:
```
HOST_<SERVICE_NAME>_<VOLUME_TYPE>=./path/to/volume
```

Examples:
- `HOST_NGINX_PROXY_MANAGER_DATA=./nginx-proxy-manager/data`
- `HOST_JELLYFIN_CONFIG=./jellyfin/config`
- `HOST_MEDIA_DATA=/mnt/big-ssd/media`

**Always provide defaults**:
```yaml
environment:
  - DATA_PATH=${HOST_VOLUMES_DIR:-./docker-volumes}/media/data
```

### Networking

Use shared networks for reverse proxy integration:

```yaml
networks:
  proxiable:
    external: true  # Managed separately
```

Document which network each service uses.

### Configuration as Code

- ✅ All configuration in `docker-compose.yml` and `.env.example`
- ✅ All secrets in `.env` (git-ignored)
- ✅ `.gitignore` includes `.env`, volume directories, temporary files
- ❌ No hardcoded IPs, domains, or API keys
- ❌ No production secrets in any tracked file

---

## Code of Conduct

This project follows a **Code of Conduct** encouraging respectful, inclusive collaboration:

- **Be respectful** — Disagree diplomatically
- **Be helpful** — Beginners and different skill levels are welcome
- **Be honest** — Admit limitations, ask for help when stuck
- **No harassment** — Discrimination, harassment, or abuse is not tolerated

---

## Questions?

- **General questions**: Open a [Discussion](https://github.com/yourrepo/discussions)
- **Bug reports**: [GitHub Issues](https://github.com/yourrepo/issues)
- **Community chat**: Join Reddit `/r/homelab`, `/r/jellyfin`, or local Discord servers

---

## Recognition

Contributors are recognized in:

- **CONTRIBUTORS.md** — Hall of fame
- **Release notes** — Thank you message in release announcements
- **GitHub** — Automatic contributor badge on repo

Thank you for making Home Lab better! 🎉
