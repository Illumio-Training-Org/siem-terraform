---
name: project-siem-lab
description: "361-SIEM Instruqt track (6 challenges, renumbered from 901) — working architecture, resolved issues, and next steps as of 2026-07-10"
metadata: 
  node_type: memory
  type: project
  originSessionId: 40c840fb-e45d-400e-a155-d26966115260
---

## 361-SIEM Track — Verified as of 2026-07-10

**Superseded this memory's 2026-06-22 snapshot — significant drift found.** Track was
renumbered from `901-SIEM` to **`361-SIEM: Detect and Investigate a Breach`** (slug `siem`,
id `npsrvxkb0lj0`) and expanded from 4 challenges to **6**. This was discovered by pulling
the live track (`instruqt track pull`) into `/Users/nathan.mitchell/claude/SIEM/labs/siem/`,
renaming the previous local copy to `labs/OLDsiem/` for comparison, and diffing every file —
**OLDsiem and the fresh pull were byte-identical**, meaning the local copy was already fully
in sync with Instruqt; nothing new came down in that pull. All the drift was between the old
*memory notes* and reality, not between local and remote.

**New challenges added since the 2026-06-22 snapshot:**
- **Challenge 5 — WannaCry Ransomware Network Forensics** (`05-wannacry-investigation`, 1800s timelimit) — this is the same WannaCry investigation content previously recorded below as "Challenge 4"; it has since been renumbered to Challenge 5 (see renumbering note below).
- **Challenge 6 — From DIY SIEM to Illumio Insights** (`06-from-siem-to-insights`, 1200s timelimit) — a capstone that reframes everything the learner just built as "hidden cost" (a table of the skills/steps required: Terraform/IAM/S3 provisioning, Fluent Bit config, OpenSearch schema mapping, KQL queries, etc. — 60–90 min for one data source in a controlled lab) and pivots to Illumio Insights as the productized alternative (pre-built dashboards, agent personas, one-click quarantine, existing segmentation policy integration). Dashboards tab on port 5601.

**Renumbering:** the "Challenge 4" WannaCry content described later in this file (recon IP
`185.220.101.47`, brute-force IP `185.220.101.34`, etc.) is now **Challenge 5**. The old
"Challenge 4" slot (`04-search-logs-dashboards`) is titled **"Challenge 4: Detect and
Investigate a Breach"** and is the original Linux/SSH-brute-force investigation (Scenario 1).
Don't confuse the two "Detect and Investigate a Breach" titles — one is the track title,
one is Challenge 4's title.

**track.yml changes vs the 2026-06-22 snapshot:** `timelimit` 5400→**8400** (140 min),
`idle_timeout` 3600→**1500**, added `lab_config.extend_ttl: 900` and
`lab_config.override_challenge_layout: false`.

**Pending items from the 2026-06-22 snapshot — status now:**
1. ~~Re-paste `setup-siem-server` fix~~ — **confirmed live**: `track_scripts/setup-siem-server` contains the `timeout 12` + `sleep 3` + `jq` doc-count-check fix (verified by grep on the pulled copy).
2. ~~Run `instruqt track push` to sync assignment.md changes~~ — **moot**: local was already byte-identical to remote at pull time, so whatever was pending got synced at some point outside this memory's tracking.
3. **Still open** — bake Terraform into the `illumio-training/siem` VM image via `resources/build-siem-image.sh` (not verified either way from files alone; would need to check the actual VM image).
4. **Still open** — run all 6 challenge Check scripts end-to-end in a live sandbox to confirm they pass (file inspection can't confirm this; needs an actual run).

---

## 901-SIEM Track — Working as of 2026-06-22 (historical — see superseding note above)

### Architecture (confirmed working end-to-end)
- **VM image**: `illumio-training/siem` (baked image with Docker, Fluent Bit v5.0.7, AWS CLI v2 pre-installed)
- **OpenSearch 2.13.0 + Dashboards 2.13.0** via docker compose, started in setup script
- **Fluent Bit**: S3 INPUT plugin does NOT exist in v5.x; `start-fluent-bit.sh` uses `aws s3 sync` to download files then `tail` plugin to process locally
- **Terraform** runs inside the lifecycle script (NOT via Instruqt's built-in Terraform integration — that doesn't inject outputs as env vars)
- **GitHub Terraform repo**: `https://github.com/Illumio-Training-Org/siem-terraform` (main branch, `main.tf` + `sample-syslog.log` at repo root)

**Why Terraform in lifecycle script:** Instruqt's built-in Terraform integration does not inject Terraform outputs as env vars on the VM. Running Terraform in the setup script allows direct capture of outputs (bucket name, IAM credentials).

### Instruqt Cloud Account Settings (aws-siem-lab)
- Services: Amazon S3, AWS IAM
- **User Managed Policies: AdministratorAccess** ← CRITICAL — required for Terraform to create S3/IAM resources
- Admin Managed Policies: AdministratorAccess (applies to console user only, NOT to `AWS_ACCESS_KEY_ID`)
- Region: US East (N. Virginia)

**Why:** The lifecycle script uses `AWS_ACCESS_KEY_ID` which maps to the student/API user. Admin Managed Policies only affect the console user, not the API credentials. User Managed Policies must include AdministratorAccess for Terraform to succeed.

### Directory Structure
```
/Users/nathan.mitchell/claude/SIEM/
├── siem/                          ← Instruqt track (instruqt track push/pull)
│   ├── track.yml
│   ├── config.yml
│   ├── assets/logo.png
│   ├── track_scripts/
│   │   └── setup-siem-server      ← lifecycle script (paste into Instruqt UI manually)
│   ├── 01-verify-the-stack/
│   │   ├── assignment.md
│   │   └── check-siem-server
│   ├── 02-configure-fluent-bit/
│   │   ├── assignment.md
│   │   └── check-siem-server
│   ├── 03-ingest-logs/
│   │   ├── assignment.md
│   │   └── check-siem-server
│   └── 04-search-logs-dashboards/
│       ├── assignment.md
│       └── check-siem-server
└── resources/                     ← supporting files (not part of Instruqt track)
    ├── LAB-GUIDE.md               ← student reference doc
    ├── sample-syslog.log          ← log file uploaded to S3 by Terraform (282 lines)
    ├── build-siem-image.sh        ← script to bake the illumio-training/siem VM image
    ├── terraform/
    │   └── main.tf                ← local master copy; push to GitHub repo
    └── SIEM-MEMORY.md             ← this memory file (canonical copy here)
```

**Note:** `track_scripts/setup-siem-server` must be pasted into the Instruqt UI manually — `instruqt track push` does NOT sync lifecycle scripts.

### Track Details
- **Title**: `901-SIEM: Detect and Investigate a Breach`
- **Track timelimit**: 5400 seconds (90 min)
- **Challenge timelimits**: Ch1=600, Ch2=900, Ch3=900, Ch4=1800

### Setup Script Flow (siem/track_scripts/setup-siem-server)
1. `sysctl -w vm.max_map_count=262144` — required by OpenSearch for mmap
2. Write docker-compose.yml and `docker compose up -d`
3. Install Terraform if not present (pinned to 1.9.8)
4. Clone `Illumio-Training-Org/siem-terraform` to `/tmp/siem-tf`, run `terraform apply`
5. Capture outputs: `s3_bucket_name`, `s3_bucket_region`, `aws_access_key_id`, `aws_secret_access_key`
6. Write student files via Python `open().write()`: `fluent-bit.conf`, `parsers.conf`, `start-fluent-bit.sh`, `verify.sh`
7. Write credentials HTML, serve on port 8080 with `python3 -m http.server`
8. Poll OpenSearch health until green/yellow before exiting

### Key Technical Details
- `DISABLE_INSTALL_DEMO_CONFIG=true` required in OpenSearch docker compose env (2.12+)
- `depends_on: - opensearch` (simple form, NOT `service_healthy`) so compose returns quickly
- Student files written with Python `open().write()` — bash heredocs get mangled by Instruqt UI editor
- Fluent Bit regex: PCRE named groups `(?<name>)` NOT Python `(?P<name>)`
- OpenSearch Dashboards 2.13.0: Index Patterns are under **Management → Dashboards Management → Index Patterns** (left sidebar — click Dashboards Management directly, not a dropdown)
- `start-fluent-bit.sh` uses `timeout 12` wrapper + `Flush 2` — Fluent Bit exits automatically after ~12s; students do NOT press Ctrl+C
- After `timeout 12` fires, script sleeps 3 seconds then queries OpenSearch with `jq` for doc count confirmation
- Fluent Bit `tail` plugin reads all records and flushes within ~2s; by timeout time 0 chunks pending is normal/correct
- Instruqt runnable code blocks use ` ```run ` as the language identifier (not ```bash)

### Challenge 4 — Security Incident Scenario
The syslog file (282 lines) tells a complete attack story across 4 hosts. Key answers:
- **Recon IP**: `185.220.101.47`
- **Brute force IP**: `185.220.101.34`
- **Compromised account**: `deploy` (~98 failed attempts before success at **10:10:01**)
- **Lateral movement targets**: `dbserver01` and `fileserver01` (from `10.0.0.10`)
- **Backdoor account**: `svc_monitor` (created on all 3 compromised hosts via `useradd`)
- **Exfiltration destination**: `91.92.251.103` (at least 2.4 GB from fileserver01; final conntrack entry `bytes=2562719744`)

Challenge 4 assignment structure: 8 investigation steps → each has a question → each question has A/B/C/D MCQ → collapsible answer key + score table at the bottom → end-of-lab notice in large orange text.

### OpenSearch Field Mapping (syslog-rfc3164 parser)
Critical for writing correct KQL queries — process names land in `ident`, not `message`:
- `host` — hostname (e.g. `webserver01`)
- `ident` — process name (e.g. `sshd`, `sudo`, `useradd`, `usermod`, `nginx`, `kernel`)
- `pid` — process ID
- `message` — text after the colon in the log line

**Correct queries:**
- `ident: sudo AND host: webserver01` ✓ (NOT `message: sudo`)
- `ident: useradd OR ident: usermod` ✓ (NOT `message: useradd`)
- `message: "Failed password" AND message: "185.220.101.34"` ✓
- `message: "Accepted password" AND message: "185.220.101.34"` ✓
- `message: "91.92.251.103"` ✓ (conntrack entries embed IP in message body)

### Resolved Issues
- OpenSearch crash-loop: `DISABLE_INSTALL_DEMO_CONFIG=true`
- S3 INPUT plugin missing from Fluent Bit 5.x: `aws s3 sync` + `tail` plugin
- Terraform not provisioning: must run in lifecycle script, not Instruqt built-in integration
- AccessDenied on S3/IAM create: User Managed Policies must include AdministratorAccess
- Fluent Bit regex named groups: `(?<name>)` not `(?P<name>)`
- Student files not created: Python `open().write()` instead of bash heredocs
- Fluent Bit hanging after ingestion: `timeout 12` wrapper + `Flush 2` + `sleep 3` before doc count check
- Doc count check used Python one-liner (fragile in escaped context) — replaced with `jq`
- KQL phrase query `message: "Failed password from 185.220.101.34"` returns no results — correct: `message: "Failed password" AND message: "185.220.101.34"`
- track.yml YAML parse error: title with colon must be quoted e.g. `title: '901-SIEM: ...'`
- Challenge 4 Step 6: `message: sudo` and `message: useradd/usermod` return no results — process names are in `ident` field; correct queries use `ident:`
- Challenge 4 Q2 ambiguous: `svc_monitor` also shows "Accepted password" from same IP — reworded to "successfully brute force to gain initial access"
- Challenge 4 Q4 wrong time: was 09:10:01, actual log shows **10:10:01**
- Challenge 4 Index Pattern creation: step 4 "click Next step", step 5 "click Create index pattern" (two-page wizard)
- Challenge 4 Step 2 point 3: must click **Update** after selecting time range

### Pending
- Re-paste `setup-siem-server` into the Instruqt UI (timeout 12 + sleep 3 + jq doc count fix won't apply until re-pasted)
- Run `instruqt track push` to sync all assignment.md changes (run buttons, Step 6 ident: fixes, Q2/Q4 fixes, time range UPDATE button, Step 2 sort-by-Time instruction, bytes-to-GB note)
- Bake Terraform into the VM image using `resources/build-siem-image.sh` to remove ~30s install time per sandbox start
- Run all 4 challenge Check scripts to confirm they pass end-to-end
