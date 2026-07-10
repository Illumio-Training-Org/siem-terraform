# siem-terraform

Supporting resources for the **361-SIEM: Detect and Investigate a Breach** Instruqt lab track.

This repository hosts the log data and infrastructure configuration consumed by the lab during student sessions. Files are fetched directly from GitHub at runtime — students do not interact with this repository.

---

## Repository Contents

### `main.tf`
Terraform configuration that provisions the AWS infrastructure used by the lab, including the S3 bucket that stores the syslog evidence file. This runs automatically inside the Instruqt sandbox during lab setup.

### `sample-syslog.log`
A synthetic Linux syslog file (282 lines) representing a complete attack chain on a fictional corporate server. Used in **Challenge 3** (log ingestion via Fluent Bit) and **Challenge 4** (security incident investigation).

The scenario covers:
- Reconnaissance from IP `185.220.101.47`
- SSH brute force attack (~98 attempts) from IP `185.220.101.34`
- Successful login to the `deploy` account at 10:10:01
- Lateral movement to `dbserver01` and `fileserver01`
- Backdoor account `svc_monitor` created across three hosts
- Data exfiltration of ~2.4 GB to `91.92.251.103`

Students ingest this file from S3 using Fluent Bit, index it into OpenSearch, then investigate the incident using OpenSearch Dashboards.

### `wannacry-events.ndjson`
Structured network event data (8,361 records, NDJSON format) extracted from a real WannaCry ransomware packet capture. Used in **Challenge 5** (WannaCry ransomware network forensics).

The dataset covers a 10-minute capture window (2020-11-18 14:10–14:21 UTC) on a fictional corporate network and contains five event types:

| Event type | Records | Description |
|---|---|---|
| `dns` | 364 | DNS queries including 5 kill switch domain lookups |
| `smb2` | 49 | SMB2 file operations including the malicious file transfer |
| `smb1` | 29 | EternalBlue propagation attempts to internal hosts |
| `arp` | 252 | Post-infection subnet scan by the infected workstation |
| `connection` | 7,667 | Outbound TCP connections to random external IPs |

Key events tagged in the data:
- `wannacry_killswitch` — queries for `www.iuqerfsodp9ifjaposdfjhgosurijfaewrwergwea.com`
- `malicious_file_transfer` — SMB2 transfer of the WannaCry payload (identified by SHA256 hash)
- `eternalblue_attempt` — SMBv1 null-session propagation attempts
- `lateral_movement` / `arp_scan` — post-infection network scanning

Students import this file directly into OpenSearch using the Bulk API, build a network security dashboard in OpenSearch Dashboards, then investigate the incident to identify patient zero, the infection vector, and the attack timeline.

> The underlying packet capture (`CORPNetwork1.pcapng`) is retained offline as source material. The NDJSON file contains network metadata only — no malware binary is present in this repository.

### `azure-flow-logs-2026-07-06T04.ndjson`
Flattened Azure NSG Flow Log data (18,385 records, NDJSON format), drawn from one real hour (2026-07-06, 04:00–05:00 UTC) of an actual Illumio demo environment's Azure flow logs. Used in **Challenge 6** (Comparing SIEM to Insights).

Each record carries `time`, `macAddress`, `srcIp`/`dstIp`, `srcPort`/`dstPort`, `protocol`/`protocolName`, `direction`, `rule` (the matching NSG rule name), `action` (allow/deny), and packet/byte counters. Risky/monitored protocols present include SSH, RDP, Telnet, FTP, SMB, VNC, WinRM, LDAP, and several database ports.

Students look up SSH, RDP, and SMB traffic directly in OpenSearch, then look up the same three in Illumio Insights' Risky Services Traffic view — a side-by-side comparison, not an investigation.

---

## How Files Are Used in the Lab

```
Instruqt sandbox (student session)
│
├── Challenge 3 — Ingest Logs
│   └── aws s3 sync → pulls sample-syslog.log from S3
│       └── Fluent Bit tails the file → indexes into OpenSearch
│
├── Challenge 4 — Investigate: Linux Breach
│   └── OpenSearch Dashboards — KQL search on syslog index
│
├── Challenge 5 — Investigate: WannaCry Ransomware
│   └── curl raw.githubusercontent.com → wannacry-events.ndjson
│       └── OpenSearch Bulk API → indexes into wannacry-events index
│           └── OpenSearch Dashboards — visualizations + investigation
│
└── Challenge 6 — Comparing SIEM to Insights
    └── curl raw.githubusercontent.com → azure-flow-logs-2026-07-06T04.ndjson
        └── OpenSearch Bulk API → indexes into azure-flows index
            └── OpenSearch Dashboards vs. Illumio Insights Risky Services Traffic
```

---

## Lab Track Details

- **Platform**: Instruqt
- **Track**: 361-SIEM: Detect and Investigate a Breach (7 challenges)
- **Stack**: OpenSearch 2.13.0 + OpenSearch Dashboards 2.13.0 (Docker)
- **Log ingestion**: Fluent Bit 5.x (syslog scenario) / OpenSearch Bulk API (ransomware + Azure flow log scenarios)
- **AWS region**: us-east-1
