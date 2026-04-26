# DreamRise — Google Cloud (GCP) Archive VM

This guide deploys **OpenClaw** and **Paperclip** on a small **Compute Engine** VM, mirroring the Oracle flow in [09-oracle-deployment.md](./09-oracle-deployment.md). Paperclip is still cloned from upstream on the VM (see [scripts/oci-paperclip.sh](../scripts/oci-paperclip.sh)); it is not vendored in this repository.

## Prior art / other plans

A workspace search did not find a separate `plan/` or `impl/` document labeled “antigravity.” This doc is the canonical GCP procedure for DreamRise; if you have an external plan file, reconcile any differences (e.g. Vertex AI vs Gemini API keys) manually.

## Credentials (single project — recommended)

Use **one** Google Cloud project and matching credentials for **both** infrastructure and the **Gemini API key** string (from [AI Studio](https://aistudio.google.com/apikey) or the API keys page for that same project). Typical `~/.zshrc` on your Mac:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/deployer-sa.json"
export GOOGLE_API_KEY="your-api-key-string"
# Optional alias (scripts treat it the same as GOOGLE_API_KEY):
# export GEMINI_API_KEY="$GOOGLE_API_KEY"
```

| What | Variable | Role |
|------|----------|------|
| **Cloud + ADC on apps** | `GOOGLE_APPLICATION_CREDENTIALS` | **Absolute path** to a **service account JSON** used for `gcloud` on your Mac and passed into OpenClaw/Paperclip on the VM ([scripts/gcp-require-app-credentials.sh](../scripts/gcp-require-app-credentials.sh), [scripts/oci-openclaw.sh](../scripts/oci-openclaw.sh), [scripts/oci-paperclip.sh](../scripts/oci-paperclip.sh)). |
| **Gemini developer API** | `GOOGLE_API_KEY` (preferred) or `GEMINI_API_KEY` | Same string for model access; [gcp-deploy-all.sh](../scripts/gcp-deploy-all.sh) syncs them if only one is set. |

Important:

- **Copy the same service-account JSON to the VM** to a path such as `$HOME/dreamrise-gcp-sa.json`, **`chmod 600`**, and set **`GOOGLE_APPLICATION_CREDENTIALS`** to that **absolute path** before `gcp-deploy-all.sh`.
- Treat the JSON like a password: restrict file permissions and rotate if leaked.
- **Create the deployer service account** (once, as a project Owner in `gcloud`): [scripts/gcp-create-deployer-sa.sh](../scripts/gcp-create-deployer-sa.sh). To mint a **new** key file at a path, set `GCP_CREATE_DEPLOYER_KEY=1` and `GOOGLE_APPLICATION_CREDENTIALS` to a **non-existent** file path, then run the script.

```bash
export GCP_PROJECT_ID=tradetalkapp-492904
bash scripts/gcp-create-deployer-sa.sh
# Optional new key file:
# export GCP_CREATE_DEPLOYER_KEY=1
# export GOOGLE_APPLICATION_CREDENTIALS="$HOME/keys/dreamrise-deployer.json"
# bash scripts/gcp-create-deployer-sa.sh
```

Confirm the **cloud** key file exists (same shell where you run `gcloud`):

```bash
test -f "${GOOGLE_APPLICATION_CREDENTIALS:?set GOOGLE_APPLICATION_CREDENTIALS to the JSON path}" && echo "OK: key file readable"
```

`gcloud` does not automatically pick up ADC for every command the way some SDKs do; activate the service account once per machine (or after the key rotates):

```bash
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project tradetalkapp-492904
```

### Same credentials in the Google Cloud Console

Mirror the same two values when working in the **browser** (Console + **Cloud Shell**) so `gcloud` and any scripts you run there match your Mac `~/.zshrc`.

1. **API key string (`GOOGLE_API_KEY`)**  
   In the Console: **APIs & Services** → [**Credentials**](https://console.cloud.google.com/apis/credentials?project=tradetalkapp-492904) → **Create credentials** → **API key** (or open an existing key and copy it). Restrict the key (HTTP referrers / APIs) per Google’s recommendations.  
   You can also create or copy a key from [Google AI Studio](https://aistudio.google.com/apikey) if you keep everything in the same Google account as this project.

2. **Service account JSON (`GOOGLE_APPLICATION_CREDENTIALS`)**  
   In the Console: **IAM & Admin** → [**Service accounts**](https://console.cloud.google.com/iam-admin/serviceaccounts?project=tradetalkapp-492904) → select your deployer account (e.g. `dreamrise-gcp-deployer` or `gemini-deployer`) → **Keys** → **Add key** → **JSON** and download the file.  
   **Do not** commit that file to git. Store it only in secure paths (`chmod 600`).

3. **Cloud Shell** (terminal in the Console)  
   Open [**Cloud Shell**](https://shell.cloud.google.com/?cloudshell=true&show=terminal&project=tradetalkapp-492904) with project **`tradetalkapp-492904`** selected in the project picker. Upload the JSON (**More** (⋮) → **Upload**), then set the same variables as on your Mac (paths are under `$HOME` in Cloud Shell):

```bash
# After uploading e.g. dreamrise-gcp-sa.json into $HOME
chmod 600 "$HOME/dreamrise-gcp-sa.json"
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/dreamrise-gcp-sa.json"
export GOOGLE_API_KEY="paste-the-api-key-from-Credentials-or-AI-Studio"
gcloud auth activate-service-account --key-file="$GOOGLE_APPLICATION_CREDENTIALS"
gcloud config set project tradetalkapp-492904
```

Cloud Shell’s home directory is **reset on reclaim** unless you use a persistent setup; for long-lived exports, keep the canonical values in **`~/.zshrc` on your Mac** (or Secret Manager) and repeat the `export` lines when you open a fresh Cloud Shell session.

To print the same snippet from this repo on your Mac:

```bash
bash scripts/gcp-print-cloudshell-env.sh
```

Before creating a VM, verify the JSON key matches the target project and that Compute is enabled:

```bash
export GCP_PROJECT_ID=tradetalkapp-492904
bash scripts/gcp-credentials-doctor.sh
```

## Target project (tradetalkapp-492904)

| Field | Value |
|-------|-------|
| **Name** | tradetalkapp (or your Console display name) |
| **Project ID** | `tradetalkapp-492904` |
| **Project number** | 933081724691 |

Use the **Project ID** for `gcloud --project=…`, the `GCP_PROJECT_ID` environment variable, and programmatic GCP clients.

## Recommended VM spec (free-tier friendly)

| Setting | Recommendation |
|---------|----------------|
| **Region / zone** | `us-central1` (or another region where your account has **Always Free** e2-micro eligibility). Example zone: `us-central1-a`. |
| **Machine type** | `e2-micro` for minimal cost; upgrade to `e2-small` if Paperclip/OpenClaw OOM during `pnpm install` or runtime. |
| **Boot disk** | Ubuntu **24.04** LTS, **30 GB** balanced PD (minimum comfortable for Node + two apps). |
| **Archive disk (optional)** | Additional standard persistent disk (e.g. **50 GB**) mounted at `/mnt/archive` for cold files. Move or symlink data only after confirming Paperclip/OpenClaw support for custom data dirs (`~/.paperclip` is the default). |
| **Network tags** | e.g. `dreamrise-gcp` — use with firewall rules below. |

## Firewall model

**Do not** expose Paperclip (`3100`) or OpenClaw (`18789`) on a `0.0.0.0/0` rule. Use **Tailscale** (same as Oracle) so dashboards stay on the tailnet.

Minimum ingress:

| Rule | Ports | Source | Purpose |
|------|-------|--------|---------|
| `allow-ssh-restricted` | TCP **22** | Your home/office IP (`x.x.x.x/32`) or [IAP for TCP forwarding](https://cloud.google.com/iap/docs/using-tcp-forwarding) | SSH bootstrap |
| `allow-tailscale-udp` (optional) | UDP **41641** | `0.0.0.0/0` | Better direct WireGuard paths for Tailscale (optional; DERP often works without it) |

After Tailscale works and you use `ssh ubuntu@dreamrise` over Tailscale, **tighten or remove** the broad SSH rule and rely on Tailscale SSH (`tailscale up --ssh`) where possible.

Example (adjust network, tags, and source IP; project ID **`tradetalkapp-492904`**):

```bash
gcloud compute firewall-rules create dreamrise-allow-ssh \
  --project=tradetalkapp-492904 \
  --network=default \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=tcp:22 \
  --source-ranges=YOUR.IP.ADDRESS.HERE/32 \
  --target-tags=dreamrise-gcp

gcloud compute firewall-rules create dreamrise-allow-tailscale-udp \
  --project=tradetalkapp-492904 \
  --network=default \
  --direction=INGRESS \
  --action=ALLOW \
  --rules=udp:41641 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=dreamrise-gcp
```

Verify you have **no** rule allowing `tcp:3100` or `tcp:18789` from the public internet.

```bash
gcloud compute firewall-rules list --project=tradetalkapp-492904 \
  --filter="direction:INGRESS" \
  --format="table(name,allowed[].map().firewall_rule().list():label=ALLOW,targetTags.list():label=TAGS)"
```

## IAM

| Identity | Use |
|----------|-----|
| **Provisioning service account** (JSON key on your Mac) | Create VMs, disks, firewall rules. Typical roles: `roles/compute.instanceAdmin.v1` plus `roles/iam.serviceAccountUser` if attaching a VM service account. |
| **VM service account** (attached to the instance, no JSON on disk) | Optional: `roles/secretmanager.secretAccessor` if you pull secrets from Secret Manager at boot. Prefer **no** admin roles on the VM identity. |

For **DreamRise on GCP**, the apps **do** expect the JSON on the VM (see bootstrap below). The deployer SA from `gcp-create-deployer-sa.sh` is intended for this same project; you can add a **narrower** VM-only SA later if you want to harden further.

### Billing (required before Compute Engine API)

Google Cloud normally **will not let you enable the Compute Engine API** until the project is **linked to an active billing account** (a payment method on file). That is separate from whether you pay each month: [Always Free](https://cloud.google.com/free/docs/free-cloud-features#compute) **e2-micro** usage can still be **$0** when you stay within free-tier limits, but the project must still have **billing enabled** for Compute to turn on.

1. As a **Billing Account Administrator** (or project Owner who can link billing), open **Billing** for the project and **link** a billing account: [Cloud Console — billing for this project](https://console.cloud.google.com/billing?project=tradetalkapp-492904).
2. After billing is linked, enable **Service Usage** and **Compute Engine** (order may matter on a brand-new project); see the next subsection.

If you must avoid GCP billing entirely, use another host for this stack (for example the [Oracle deployment](./09-oracle-deployment.md) path in this repo) instead of Compute Engine.

### One-time: enable Google Cloud APIs (before `gcp-create-instance.sh`)

If `gcloud compute` returns **`SERVICE_DISABLED`** or **`PERMISSION_DENIED`** mentioning that **Compute Engine API has not been used**, a **project Owner** (human account with IAM access to the project) must enable APIs once in the Console. The deploy service account (`gemini-deployer@…`) cannot always bootstrap **Service Usage** when it is still off.

If the Console **refuses to enable Compute Engine** until billing is fixed, complete the [billing step above](#billing-required-before-compute-engine-api) first.

Print the exact links for **`tradetalkapp-492904`**:

```bash
bash scripts/gcp-print-api-enable-urls.sh
```

After **Compute Engine** shows Enabled, wait a few minutes, then run `scripts/gcp-create-instance.sh` again.

## Create the VM from your Mac

Use the helper (sets sensible defaults; override with env vars):

```bash
export GCP_PROJECT_ID="tradetalkapp-492904"
export GCP_ZONE="${GCP_ZONE:-us-central1-a}"
export GCP_VM_NAME="${GCP_VM_NAME:-dreamrise-gcp}"
bash scripts/gcp-create-instance.sh
```

If you set `GCP_ARCHIVE_DISK_GB`, the extra disk is attached raw. After first SSH, find the device (`ls -l /dev/disk/by-id/google-*-archive` — the suffix matches `${GCP_VM_NAME}-archive`), then format and mount (example uses that by-id path; **destructive** if the disk already has data):

```bash
ARCH_DEV=/dev/disk/by-id/google-${GCP_VM_NAME}-archive
sudo mkfs.ext4 -F "$ARCH_DEV"
sudo mkdir -p /mnt/archive
sudo mount "$ARCH_DEV" /mnt/archive
echo "$ARCH_DEV /mnt/archive ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
```

Run these lines on the VM with `GCP_VM_NAME` exported to match `gcp-create-instance.sh`, or substitute the concrete by-id path from `ls`.

Then SSH (replace with the external IP printed by the script):

```bash
gcloud compute ssh "$GCP_VM_NAME" --project=tradetalkapp-492904 --zone="$GCP_ZONE"
```

## Bootstrap on the VM

1. Copy scripts from this repo (from your Mac):

```bash
gcloud compute scp --recurse --project=tradetalkapp-492904 --zone="$GCP_ZONE" \
     scripts/gcp-*.sh scripts/oci-*.sh ubuntu@${GCP_VM_NAME}:~/
```

2. Copy the **service account JSON** to the VM (path on Mac from `GOOGLE_APPLICATION_CREDENTIALS` in your shell):

```bash
gcloud compute scp --project=tradetalkapp-492904 --zone="$GCP_ZONE" \
  "$GOOGLE_APPLICATION_CREDENTIALS" "ubuntu@${GCP_VM_NAME}:~/dreamrise-gcp-sa.json"
```

3. On the VM, export **absolute** paths and keys, then deploy. `gcp-deploy-all.sh` sources [scripts/gcp-require-app-credentials.sh](../scripts/gcp-require-app-credentials.sh) first: the JSON **must** exist on the VM and `GOOGLE_APPLICATION_CREDENTIALS` must be set.

   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="$HOME/dreamrise-gcp-sa.json"
   export GOOGLE_API_KEY="your-key"   # same value as in ~/.zshrc on your Mac
   export TELEGRAM_BOT_TOKEN="your-token"   # optional; script can prompt
   bash ~/gcp-deploy-all.sh
   ```

This runs: shared OS setup → Tailscale → OpenClaw → Telegram → Paperclip → DreamRise company + CEO (same order as [scripts/oci-deploy-all.sh](../scripts/oci-deploy-all.sh)). It does **not** run Oracle VCN lockdown; use GCP firewall rules instead.

## Secrets (optional): Secret Manager

1. Create secrets (example names):

   ```bash
   echo -n "$GOOGLE_API_KEY" | gcloud secrets create google-api-key --project=tradetalkapp-492904 --data-file=-
   echo -n "$TELEGRAM_BOT_TOKEN" | gcloud secrets create telegram-bot-token --project=tradetalkapp-492904 --data-file=-
   ```

2. Grant the **VM** service account accessor on those secrets.

3. On first SSH session, before `gcp-deploy-all.sh`:

   ```bash
   export GOOGLE_API_KEY="$(gcloud secrets versions access latest --project=tradetalkapp-492904 --secret=google-api-key)"
   export TELEGRAM_BOT_TOKEN="$(gcloud secrets versions access latest --project=tradetalkapp-492904 --secret=telegram-bot-token)"
   ```

   If you store the JSON in Secret Manager, materialize it to a file (example) and point ADC at it:

   ```bash
   install -m 600 /dev/null "$HOME/dreamrise-gcp-sa.json"
   gcloud secrets versions access latest --project=tradetalkapp-492904 --secret=gcp-sa-json >"$HOME/dreamrise-gcp-sa.json"
   chmod 600 "$HOME/dreamrise-gcp-sa.json"
   export GOOGLE_APPLICATION_CREDENTIALS="$HOME/dreamrise-gcp-sa.json"
   ```

Alternatively keep exporting secrets only in your SSH session (no Secret Manager) for a personal archive VM.

## Verify

On the VM:

```bash
bash ~/gcp-verify.sh
```

From your laptop (Tailscale): `http://dreamrise:3100` and OpenClaw via Tailscale serve on `:18789` (see [09-oracle-deployment.md](./09-oracle-deployment.md) for service commands).

Telegram pairing matches Oracle:

```bash
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

## Cost notes

| Item | Notes |
|------|------|
| Billing account | **Required** to enable Compute Engine on the project; does not by itself mean you will be charged beyond [Always Free](https://cloud.google.com/free/docs/free-cloud-features#compute) if you size the VM and disks within free-tier rules. |
| e2-micro | Often **$0** within Always Free limits **after** billing is linked; confirm for your project/region. |
| Disk | Standard PD beyond free thresholds may incur small charges. |
| Gemini / Telegram | Same as Oracle doc — API and bot usage, not GCP compute. |

## Files reference

| File | Purpose |
|------|---------|
| [scripts/gcp-create-instance.sh](../scripts/gcp-create-instance.sh) | Example `gcloud` instance create + tags |
| [scripts/gcp-setup.sh](../scripts/gcp-setup.sh) | Phase 1: delegates to shared `oci-setup.sh` |
| [scripts/gcp-deploy-all.sh](../scripts/gcp-deploy-all.sh) | Full deploy on the VM; requires `GOOGLE_APPLICATION_CREDENTIALS` on the VM |
| [scripts/gcp-require-app-credentials.sh](../scripts/gcp-require-app-credentials.sh) | Validates ADC JSON path before deploy |
| [scripts/gcp-print-api-enable-urls.sh](../scripts/gcp-print-api-enable-urls.sh) | Console URLs when APIs are disabled on the project |
| [scripts/gcp-create-deployer-sa.sh](../scripts/gcp-create-deployer-sa.sh) | Create `dreamrise-gcp-deployer` SA + IAM (optional new JSON key) |
| [scripts/gcp-print-cloudshell-env.sh](../scripts/gcp-print-cloudshell-env.sh) | Copy-paste exports for Cloud Shell (matches `.zshrc`) |
| [scripts/gcp-credentials-doctor.sh](../scripts/gcp-credentials-doctor.sh) | Check SA JSON vs `GCP_PROJECT_ID` and Compute API |
| [scripts/gcp-grant-compute-roles.sh](../scripts/gcp-grant-compute-roles.sh) | **Owner only:** grant `tradetalk-sa` Compute + related roles |
| [scripts/gcp-verify.sh](../scripts/gcp-verify.sh) | Health checks + firewall sanity (read-only `gcloud` if configured) |
| [scripts/oci-*.sh](../scripts/) | Shared install phases (Tailscale, OpenClaw, Paperclip, …) |
| [config/openclaw-oracle.json](../config/openclaw-oracle.json) | OpenClaw template (same shape on GCP) |

## Troubleshooting

- **`gcp-require-app-credentials.sh` / missing JSON on VM**: Copy the key with `gcloud compute scp` (see bootstrap), use an **absolute** path, and `chmod 600` the file.
- **OOM during install or run**: Resize to `e2-small` or stop one service temporarily; reduce OpenClaw `maxConcurrent` in config.
- **`gcloud` permission errors**: Re-check roles on the provisioning service account; ensure Compute Engine API is enabled.
- **Compute Engine API will not enable (billing)**: Link a billing account to the project ([billing console](https://console.cloud.google.com/billing?project=tradetalkapp-492904)), then enable Compute again.
- **Tailscale on SSH-only VM**: Complete browser auth URL from the SSH session’s printed `tailscale up` link.
- **Stuck after “Building dependency tree…” in Phase 1**: `apt upgrade` was waiting on a debconf prompt. [scripts/oci-setup.sh](../scripts/oci-setup.sh) now uses `DEBIAN_FRONTEND=noninteractive` and `--force-confold` on `apt-get upgrade`. **Ctrl+C** the run, `scp` the updated `oci-setup.sh` (or pull the repo on the VM), then re-run `bash ~/gcp-deploy-all.sh` (or only `bash ~/oci-setup.sh`).

See also [Oracle deployment](./09-oracle-deployment.md) for OpenClaw/Paperclip log locations and Telegram behavior.
