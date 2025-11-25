# Roadmap

Roadmap and release with main steps

PHASE 1-FOUNDEDATIONS (1-2 months)

1. Define Scope & Use Cases  
2. Core Architecture Design

PHASE 2-BUILD CORE CAPABILITIES (1-3 months)

3. Asset Discovery Engine  
4. Continuous Monitoring  
5. Exposure and Vulnerability Scanning  
6. Risk Prioritization & Scoring  
7. Dashboard, Alerts & APIs

PHASE 3 - ENRICHMENT & ADVANCED FEATURES (3-6 months)

8. Threat Intelligence Integration  
9. Automation & Remediation  
10. Reporting & Compliance

PHASE 4 - SCALING & MATURITY (6-12 months)

11. AI/ML & Predictive Analytics  
12. Multi-Tenant  
13. Integrations Ecosystem  
14. Benchmarking & Continuous Improvement

Example 6-Month MVP Timeline

Key Open Source Building Blocks

Building an External Attack Surface Management (EASM) platform or capability is a significant but very achievable project if structured right. Below is a step-by-step roadmap, structured for either:

- a product startup building an EASM solution, or  
- a security team implementing EASM internally for their organization.

I'll clarify both perspectives where relevant.

# Roadmap and release with main steps

![](images/4d55901409b4b5d80f690ecf3edcc69d1a84f3db344e1d05036f74ca1eb68956.jpg)

Release scope with all steps

<table><tr><td>Asset Discovery</td><td>~ 4 months.
Foundations &amp; Inventory
· Seeds → normalize → passive discovery (CT, passive DNS, amass/subfinder).
· Scope filter &amp; de-dup; DNS resolve; light web/TLS enrichment.
· Evidence bundle; attribution (ASN/cloud) + confidence labels (Owned/Suspected /Third-party).
· Persist + lineage + delta flags; inventory UI/API/CSV.
· Cloud endpoints: basic detection via ASN/provider &amp; patterns (no deep cloud scan).</td><td>~ 2 months.
Coverage, Scale &amp; UX
· Scheduler &amp; per-org budgets; concurrency/backoff; better provider heuristics.
· UI filters (provider/ASN/tech), inventory trends (sparkline).
· Bulk seed import; saved views.</td><td>~ 2 months.
Confidence &amp; Evidence UX
· Ownership heuristics v2 (SAN/CNAME/WH OIS signals), signed evidence downloads.
· Optional screenshots (feature flag).
· Compare competitors qualitatively (positioning) without replicating proprietary datasets.</td><td>~ 1 months. Change Intelligence &amp; Alerts
· Hotspots (fastest-growing exposure), alerts for new/changed assets (webhook/Slack/e-mail) with retry/backoff.
· Optional “active checks” add-on (non-GPL only; or our own probes) within strict budgets.</td><td></td></tr><tr><td>Asset Classification</td><td>· Define classification taxonomy (Type, Sensitivity, Exposure, Ownership).
· Rules-based classification engine (deterministic logic).
· Manual override and tagging capability.</td><td>· Enhance classification accuracy with contextual intelligence.</td><td>· Introduce adaptive classification and prioritize high-risk assets.</td><td>· Make classification enterprise-ready with compliance, integration, and scalability.</td><td></td></tr><tr><td>Vulnerability &amp; Exposure Detection</td><td>Exposure Validation
· TCP Reachability
Implement asynchronous socket checks for target IPs/domains and key ports (80, 443, 22, 25, 8080).
Output:</td><td>Basic Vulnerability Mapping
· Feed Integration (NVD)
Sync NVD JSON feed (daily or weekly). Store CVE ID, CVSS, affected product/version.</td><td>Enrichment and Evidence
· Exploitability Check
Query Exploit-DB API by CVE or product keyword. Add flag exploit_ava</td><td>Context Integration
· Risk Contextualization Output
Export structured findings to JSON or message queue. Fields: asset_id,</td><td></td></tr><tr><td></td><td>open/closed status + response latency.
· HTTP Banner Extraction Perform basic HTTP requests, extract headers (Server, X-Powered-By, Content-Type, Set-Cookie).
· Storage Layer (SQLite/PostgreSQL)</td><td>· Rule-Based Matching
Match banners to CVE entries using regex or substring rules
· Result Linking
Output: asset_id → potential_cve → confidence_score (static low)
Store in findings table.</td><td>ilable with reference link.
· Evidence Capture Store full HTTP response bodies and headers for validation snapshots.
Archive raw data under /evidence/{asset_id}/{timestamp}.
· Confidence Scoring</td><td>CVE, severity, confidence, exploit_available, timestamp.
· Asset Metadata Linking Join with asset inventory:
· Business criticality
· Data sensitivity
· Exposure type (internal/external)
Enrich final output for prioritization.</td><td></td></tr><tr><td>Risk Contextualization</td><td>Context Enrichment
· External/internal classification via IP range or Shodan API
· Map asset → business service → owner
· Metadata from CMDB
· Define taxonomy &amp; Tag assets accordingly (PCI, PII, PHI, Confidential 1, Public,...)</td><td>Risk Scoring &amp; Correlation
Rule-based formula: Exposure_Score = (Criticality*0.5)+(Severity*0.3)+
(Exploitability*0.2)
· Ingest EPSS API, CISA KEV feed
· Append exploitability, kev, ti_score</td><td>Prioritization
· Ranking logically by Exposure_Score,
data_sensitivity, and kev
· Generate prioritized remediation list</td><td>Optimization
· Record outcomes for future learning
· Write API docs
· Running automatically each scan cycle</td><td>· Explainable Risk Scoring Models
· Dynamic Context Updates
· Cross-correlation of CVEs and attack surface exposure (which are truly exploitable)</td></tr><tr><td>Continuous Monitoring &amp; Alerting</td><td>Real-Time Monitoring &amp; Core Alerts
· Continuous passive monitoring (DNS, CT logs, certificate transparency).
· Real-time event streaming for cloud resources</td><td>Intelligence &amp; Multi-Channel
· Continuous vulnerability feed integration (NVD, vendor advisories).
· Real-time threat intelligence correlation.
· Risk scoring engine (severity +</td><td>Adaptive &amp; Predictive
· Adaptive monitoring frequency (increase when threats detected).
· Predictive alerting (ML-based anomaly detection).</td><td>Advanced Intelligence
· Dark web monitoring (continuous breach data tracking).
· Active exploit detection (honeypot integration).</td><td>Autonomous Response
· Auto remediation workflows (one-click &amp; zero-touch fixes).
· Compliance-driven continuous controls (GDPR/SOC2/ISO2 7001 real-time checks).</td></tr><tr><td></td><td>(AWS/Azure/GCP webhooks).Live change detection (immediate diff on asset state changes).Basic alert rules with instant notification. Simple severity mapping (CRITICAL/HIGH/MEDIUM/LOW).Email delivery channel Alert fingerprinting &amp; basic dedduplication (6-24hr windows).</td><td>exploitability + asset value).Slack/Teams/webh ook delivery with retry/backoff ALERT grouping for related findings. Smart routing by asset owner/type Streaming metrics &amp; live dashboards.</td><td>Alert enrichment pipeline (auto-add CVE details, remediation steps).False positive learning &amp; suppression.Customer alert preferences (thresholds, quiet hours, custom rules).PagerDuty/SIEM/ti cking integration.MTTD/MTTR tracking.</td><td>Event-driven auto- remediation triggers.SMS/phone alerts for critical issues ALERT fatigue ML (optimize based on user response patterns).Meta-monitoring (self-health checks).API-first alert management.</td><td>Financial impact modeling (live breach cost estimation).Predictive asset discovery (find assets before they go live).Cross-customer threat correlation (anonymized).Natural language alert queries.Self-tuning alert thresholds.</td></tr><tr><td>Reporting &amp; Integration</td><td>Foundations &amp; Basic ReportingCore report types:asset inventory, vulnerability summary(PDF/CSV export).Basic UI/API/PDF/CSV export.Evidence; attribution (provider, discovery method, timestamp) + confidence labels (if available).ITSM connector (Jira/ServiceNow): write-only ticket creation from high-severity findings.Basic REST API(v1) for asset/finding queries;PostgreSQL/Mongo DB storage.</td><td>Risk Context &amp; Bidi-directional WorkflowsImplement risk scoring engine with reporting: severity normalization, exploitability assessment, business context (asset criticality, owner).Executive snapshot reports: KPI tiles, 7/30/90-day sparklines, top 5 risks with recommended actions.Technical deep-dive reports for SecOps: full evidence, remediation steps, confidence scoring, filterable tables.Bidirectional ITSM sync: pull ticket status back from</td><td>Compliance &amp; BI IntegrationCompliance reports:GDPR/CCPA/PCI DSS mapping, immutable audit trails, attestations.Trends &amp; program metrics: time-series charts, heatmaps, cohort analysis(BU/region/cloud).Data lake integration: long-term retention (2+ years), BI-friendly formats.Custom Export filtersAutomated SOAR playbooks trigger</td><td>Change Intelligence &amp; AutomationHotspots: fastest-growing exposure categories, delta/trend alerts ALERTs for new/changed findings:webhook/Slack/Tea ms/emails.Automated remediation-workflows: approved-action-playbooks for low-risk findings.Low Priority: Forecasting &amp; predictive analytics: AI/ML risk prediction, exploit likelihood scoring.</td><td></td></tr></table>

Jira/ServiceNow, reflect in platform.

- REST API (v2): incremental sync, pagination, ...  
Changes digest/alerts

# PHASE 1-FOUNDEDATIONS (1-2 months)

# 1. Define Scope & Use Cases

EASM can cover several domains — you must define what your MVP (Minimum Viable Product) or first use case will target.

# Possible Scopes:

- Asset discovery & inventory (domains, IPs, subdomains, cloud services)  
- Continuous exposure monitoring (open ports, SSL, misconfigurations)  
- Risk scoring & prioritization  
- Threat intelligence integration  
- Alerting & reporting

Startup view: Start with discovery + classification + continuous monitoring.  
Enterprise view: Map this to compliance (CIS, NIST, ISO 27001) and risk posture dashboards.

# 2. Core Architecture Design

# Architecture layers:

<table><tr><td>Layer</td><td>Description</td><td>Key Technologies</td></tr><tr><td>1. Discovery Engine</td><td>Internet-wide enumeration, DNS/WHOIS, certificate transparency, Shodan/Censys APIs</td><td>Python, Go, Rust; libraries like dnspython , asyncio , masscan , amass</td></tr><tr><td>2. Data Ingestion &amp; Normalization</td><td>Clean, de-duplicate, tag asset data</td><td>Kafka, Redis, Elasticsearch, PostgreSQL</td></tr><tr><td>3. Risk/Exposure Analysis</td><td>Scan for vulnerabilities, misconfigurations, expired certs, open ports</td><td>Nmap, OpenVAS, custom scanners</td></tr><tr><td>4. Risk Scoring &amp; Correlation</td><td>Combine findings into exposure score</td><td>ML models or rule-based scoring</td></tr><tr><td>5. Dashboard &amp; Reporting</td><td>Visualization &amp; alerting</td><td>ReactJS + NodeJS + Grafana/Metabase</td></tr><tr><td>6. Automation &amp; API</td><td>Integrations (SIEM, SOAR, CMDB, Jira)</td><td>REST/GraphQL API</td></tr></table>

# Security-first design:

- Use a sandboxed scanning environment.

- Ensure compliance with scanning ethics (only owned or authorized targets).

![](images/e83136bae6db99880d307948ba0259230553649d7d06fba581b23ff009b418a6.jpg)

# PHASE 2-BUILD CORE CAPABILITIES (1-3 months)

# 3. Asset Discovery Engine

Build or integrate modules for:

- Domain Enumeration: DNS, subdomain brute-force, reverse DNS.  
- Certificate Transparency Lookup: Identify unknown domains via SSL certificates.  
- IP/Range Scanning: Identify live hosts, ports, banners.  
Cloud Asset Discovery: AWS, Azure, GCP APIs.

Tools to leverage:

. amass , subfinder , shodan , censys , masscan , httpx , naabu , nmap .

Output unified into:

```txt
1 { "asset_id": "...", "type": "subdomain", "ip": "192.168.1.10", "status": "alive", "tech_stack": ["nginx", "wordpress"], "source": "crit.sh" }
```

# 4. Continuous Monitoring

- Automate rescans (daily / weekly).  
- Detect new or removed assets.  
- Implement delta-based notifications (only alert when something changes).

Tech: Celery / Airflow for scheduling, Kafka or Redis for event streaming.

# 5. Exposure and Vulnerability Scanning

Focus on:

- SSL/TLS issues  
- Open ports & weak protocols  
- Misconfigured storage (e.g. public S3)  
- Known CVEs for detected services (e.g. Apache, Nginx)

# Integrations:

OpenVAS, Nuclei templates, Nessus API, or your own lightweight scanner.

# 6. Risk Prioritization & Scoring

Define a scoring model:

```txt
1 Exposure_Score = (Criticality * 0.5) + (Severity * 0.3) + (Exploitability * 0.2)
```

Include contextual data (asset importance, business value).

# 7. Dashboard, Alerts & APIs

- Build a frontend dashboard (React / Next.js).  
- Provide APIs for integration with SIEM, SOAR, CMDB.  
Support email / Slack / Teams alerts.

Example UI features:

- Asset inventory view  
- Exposure timeline  
- Risk heatmap  
- Top risky assets

# PHASE 3-ENRICHMENT & ADVANCED FEATURES (3-6 months)

# 8. Threat Intelligence Integration

Enhance your findings using:

- IP/Domain reputation feeds (AbuseIPDB, VirusTotal, AlienVault OTX)  
Dark web mentions  
- Credential leaks

Helps identify real exploit attempts or targeted exposures.

# 9. Automation & Remediation

Integrate remediation workflows:

- Create tickets automatically (Jira, ServiceNow)  
- Auto-enable risky services (via API or IaC)  
- Send structured data to SOAR

# 10. Reporting & Compliance

Generate:

- Exposure reports (weekly/monthly/quarterly)  
Compliance mapping (CIS, NIST, ISO)  
Executive dashboards (PDF / Power BI)

# PHASE 4 - SCALING & MATURITY (6-12 months)

# 11. AI/ML & Predictive Analytics

Train models for:

Predicting high-risk assets  
Classifying technologies  
- Prioritizing exposures automatically

Example: Use NLP to match CVE descriptions with asset banners.

# 12. Multi-Tenant

If building a SaaS product:

- Build multi-tenant architecture with isolated data per region/country/client.  
- Add RBAC, SSO, and billing (Stripe, Paddle, etc.)  
- Offer Managed EASM Services (continuous monitoring + analyst review)

# 13. Integrations Ecosystem

Integrate with:

- SIEM (Splunk, Sentinel)  
- CMDB(ServiceNow)  
Cloud Security Posture (Prisma, Wiz)

# 14. Benchmarking & Continuous Improvement

- Benchmark your EASM coverage (assets discovered vs. total).  
- Track MTTD (mean time to detect exposure).  
- Gather user feedback & fine-tune alerts.

# Example 6-Month MVP Timeline

<table><tr><td>Month</td><td>Milestone</td></tr><tr><td>1</td><td>Architecture design, target definition</td></tr><tr><td>2</td><td>Asset discovery prototype</td></tr><tr><td>3</td><td>Exposure scanning &amp; risk scoring</td></tr><tr><td>4</td><td>Dashboard + API integration</td></tr><tr><td>5</td><td>Continuous monitoring, notifications</td></tr><tr><td>6</td><td>Threat intelligence integration + beta testing</td></tr></table>

# Key Open Source Building Blocks

<table><tr><td>Area</td><td>Recommended Tools</td></tr><tr><td>Discovery</td><td>amass, subfinder, crt.sh, massdns</td></tr><tr><td>Scanning</td><td>nmap, nuclei, masscan, httpx</td></tr><tr><td>Data Pipeline</td><td>Kafka, PostgreSQL, MongoDB, Elasticsearch</td></tr><tr><td>Backend</td><td>Python Django/FASTAPI</td></tr><tr><td>Frontend</td><td>ReactJS, Grafana</td></tr><tr><td>Automation</td><td>Celery, Airflow</td></tr><tr><td>Visualization</td><td>Plotly, Recharts, Metabase</td></tr></table>
