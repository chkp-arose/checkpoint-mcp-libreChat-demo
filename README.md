# Check Point MCP + LibreChat Demo

A fully self-contained, Docker-based deployment of [LibreChat](https://librechat.ai) pre-configured with all available [Check Point MCP servers](https://github.com/CheckPointSW/mcp-servers). This demo enables security teams to interact with their Check Point infrastructure using natural language — querying policies, analyzing logs, assessing threats, and generating executive-ready reports — all from a single, browser-based AI chat interface.

---

## What This Includes

- **LibreChat** — An open-source, self-hosted AI chat UI compatible with OpenAI, Azure OpenAI, Anthropic, and more
- **All Check Point MCP Servers** — Pre-configured as user-provisioned stdio MCP servers, including:
  - Quantum Management, Management Logs, Threat Prevention, HTTPS Inspection
  - Quantum Gateway CLI & Connection Analysis
  - Harmony SASE, Spark Management, Gaia OS
  - Threat Emulation, Reputation Service
  - Argos External Risk Management
  - CPInfo Analysis
  - Check Point Documentation Assistant
- **Sandpack Bundler** — A self-hosted code sandbox bundler for rendering interactive HTML/React artifacts inline in the chat, keeping execution local and eliminating CDN dependency and CORS issues
- **Automatic Self-Signed TLS** — An init container generates a self-signed certificate at first launch so the deployment is HTTPS-ready out of the box
- **Supporting Services** — MongoDB, Meilisearch, pgvector, and the LibreChat RAG API, all orchestrated via a single `docker-compose.yml`

---

## Prerequisites

- Docker Engine and Docker Compose installed on the target host
- Outbound internet access (to pull images and npm packages on first run)
- An API key for at least one LLM provider (OpenAI, Azure OpenAI, Anthropic, etc.)
- Credentials for the Check Point product(s) you wish to query

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/chkp-arose/checkpoint-mcp-libreChat-demo.git
cd checkpoint-mcp-libreChat-demo
```

### 2. Configure Your Environment

Copy the example environment file and edit it with your values:

```bash
cp .env.example .env
nano .env
```

#### Environment Variable Reference

**LibreChat Security Credentials**

These four values are used to encrypt user credentials and sign authentication tokens. The defaults in `.env.example` are placeholders — **you must change these before deploying**, especially in any shared or production environment.

| Variable | Description |
|---|---|
| `CREDS_KEY` | 32-byte hex key used to encrypt stored API keys and credentials |
| `CREDS_IV` | 16-byte hex initialization vector used with `CREDS_KEY` |
| `JWT_SECRET` | Secret used to sign user session tokens |
| `JWT_REFRESH_SECRET` | Secret used to sign token refresh flows |

> ⚠️ **These values must be unique per deployment.** Use the official generator at [https://www.librechat.ai/toolkit/creds_generator](https://www.librechat.ai/toolkit/creds_generator) to generate a secure set.

**Ports**

| Variable | Default | Description |
|---|---|---|
| `LIBRECHAT_HTTP_PORT` | `8084` | Host port for HTTP (redirects to HTTPS) |
| `LIBRECHAT_HTTPS_PORT` | `4434` | Host port for HTTPS |
| `LIBRECHAT_API_PORT` | `3080` | Host port for the LibreChat API |
| `SANDPACK_PORT` | `8080` | Host port for the Sandpack bundler |

**TLS Certificate**

| Variable | Description |
|---|---|
| `SERVER_IP` | The IP address of your host server. Used to generate the self-signed TLS certificate with the correct Subject Alternative Name (SAN). Set this to the IP address you will use to access LibreChat in your browser. |

> For additional LibreChat configuration options (RAG, Meilisearch, email, OAuth, etc.), refer to the official documentation: [https://www.librechat.ai/docs/configuration/dotenv](https://www.librechat.ai/docs/configuration/dotenv)

### 3. A Note on the Self-Signed Certificate

This deployment includes an init container that automatically generates a self-signed TLS certificate on first launch using the `SERVER_IP` you configured above. This ensures the deployment is served over HTTPS, which is required for certain browser security APIs used by the Sandpack artifact renderer.

When you first access the UI in your browser, you will see a security warning. This is expected for self-signed certificates. Click **Advanced → Proceed** (or your browser's equivalent) to continue. This warning only appears on first access per browser.

If your organization requires a trusted certificate, you can replace the generated files in `./client/certs/` with your own `server.crt` and `server.key` before starting the stack.

### 4. Start the Stack

```bash
docker compose up -d
```

On first launch, Docker will pull all required images and the cert-generator init container will create your TLS certificate before NGINX starts. Subsequent launches will be significantly faster.

To monitor startup progress:

```bash
docker compose logs -f
```

---

## Using the Application

### Accessing the UI

Open your browser and navigate to:

```
https://YOUR_SERVER_IP:4434
```

> Replace `YOUR_SERVER_IP` with the IP address you set in `SERVER_IP` in your `.env` file.

### Creating Your Account

1. Click **Register** on the login page
2. Fill in your name, username, email address, and password
3. You will be redirected to the login page — sign in with the credentials you just created

### Configuring an LLM Provider

Before you can chat, you need to connect at least one AI model provider:

1. Click the **model selector** in the top-left corner of the chat interface
2. Next to each provider (OpenAI, Anthropic, etc.) you will see a **gear icon** — click it to enter your API key
3. Your key is stored securely and associated with your account only

> LibreChat supports OpenAI, Azure OpenAI, Anthropic, Google, and many more. Refer to [https://www.librechat.ai/docs/configuration](https://www.librechat.ai/docs/configuration) for the full list of supported providers.

### Configuring Check Point MCP Servers

All Check Point MCP servers are pre-configured in this deployment. Each user must supply their own credentials for the products they wish to use. Credentials are stored securely per user account.

1. **Open the right-side control panel** by clicking the **arrow (›)** on the right edge of the interface
2. Click **MCP Settings**
3. Browse the list of available Check Point MCP servers
4. Click the **connect icon** next to the server you wish to use
5. A credential dialog will appear — fill in the required fields

> **Important:** Many MCP servers support multiple authentication modes. For example, the Quantum Management server supports:
> - **Option A — Smart-1 Cloud:** Provide your Smart-1 Cloud tenant URL and API key
> - **Option B — On-Premises (API Key):** Provide your Management Server IP and API key
> - **Option C — On-Premises (Username/Password):** Provide your Management Server IP, username, and password
>
> Fill in only the fields relevant to your environment. Optional fields (such as port or region) can be left blank to use their defaults.

6. Click **Save**, then click **Initialize** to establish the connection

### Starting a Chat Session with MCP Tools

1. Start a **New Chat**
2. From the MCP tools selector, ensure the MCP server(s) you initialized are **selected for this session**
3. Type your query and send

---

## Example Queries

Once your MCP servers are configured, you can interact with your Check Point environment using natural language. Here are some examples to get you started:

**Security Policy Compliance Analysis**
> *"Analyze my access control policy for compliance with PCI DSS 4.0 and generate an interactive HTML report summarizing the findings, gaps, and recommended remediations — formatted for presentation to executive leadership."*

**Threat Investigation**
> *"Review the last 24 hours of firewall logs and identify any connections to known malicious IP addresses or domains. Summarize the top threats and affected internal hosts."*

**Gateway Diagnostics**
> *"Run a health check on all managed gateways and highlight any with high CPU utilization, pending policy installations, or SIC communication issues."*

**Reputation Lookup**
> *"Check the reputation of the following IPs and URLs from my incident ticket and tell me if any are classified as malicious or suspicious."*

**Policy Optimization**
> *"Identify unused or shadowed rules in my security policy and suggest which ones are safe to remove or consolidate."*

---

## Architecture Overview

```
Browser (HTTPS)
      │
      ▼
┌─────────────┐
│  NGINX      │  (LibreChat-NGINX) — TLS termination, reverse proxy
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌──────────────┐     ┌───────────────┐
│ LibreChat   │────▶│   MongoDB    │     │  Meilisearch  │
│     API     │     └──────────────┘     └───────────────┘
└──────┬──────┘
       │ stdio (npx)
       ▼
┌─────────────────────────────────────┐
│     Check Point MCP Servers         │
│  (spawned as child processes)       │
│                                     │
│  quantum-management  │  mgmt-logs   │
│  threat-prevention   │  gw-cli      │
│  harmony-sase        │  gaia        │
│  threat-emulation    │  reputation  │
│  spark-management    │  argos-erm   │
│  cpinfo-analysis     │  docs        │
└────────────────┬────────────────────┘
                 │  HTTPS
                 ▼
       Check Point Infrastructure
    (Smart-1 Cloud / On-Premises MGMT)
```

---

## Troubleshooting

**Browser shows certificate error**
This is expected for self-signed certificates. Click **Advanced → Proceed** to continue.

**MCP server fails to initialize**
Verify that your credentials are correct and that the LibreChat API container has network access to your Check Point management host. For on-premises deployments, ensure the management server IP is reachable from the Docker host.

**Sandpack artifacts not rendering**
The Sandpack bundler runs locally on port `8080` by default. Ensure `SANDPACK_BUNDLER_URL` is correctly set in your `.env` pointing to `http://YOUR_SERVER_IP:8080` and that you are accessing LibreChat over HTTPS (required for browser crypto APIs used by Sandpack).

**Viewing logs**
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f client
```

---

## Resources

- [LibreChat Documentation](https://www.librechat.ai/docs)
- [LibreChat Credentials Generator](https://www.librechat.ai/toolkit/creds_generator)
- [Check Point MCP Servers Repository](https://github.com/CheckPointSW/mcp-servers)
- [Check Point MCP Server Website](https://mcp.checkpoint.com)
- [Model Context Protocol Specification](https://modelcontextprotocol.io)

---

## Disclaimer

This project is provided for demonstration and educational purposes only.

This software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose, and non-infringement. In no event shall the
authors or contributors be liable for any claim, damages, or other liability,
whether in an action of contract, tort, or otherwise, arising from, out of,
or in connection with the software or the use or other dealings in the software.

This project is not officially supported by Check Point Software Technologies Ltd.
Use at your own risk.

By using this software, you agree that:
- You are solely responsible for securing your deployment
- You are solely responsible for any credentials or API keys configured
- This is not intended for production use without independent security review

## License

This project is provided as a demo and is not officially supported by Check Point Software Technologies. Check Point MCP servers are open source and available under the [MIT License](https://github.com/CheckPointSW/mcp-servers/blob/main/LICENSE). LibreChat is open source and available under its respective license at [https://github.com/danny-avila/LibreChat](https://github.com/danny-avila/LibreChat).