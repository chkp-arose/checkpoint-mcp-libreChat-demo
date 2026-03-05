# checkpoint-docs-mcp.Dockerfile
FROM ghcr.io/sparfenyuk/mcp-proxy:latest

# Install Node.js and npm (Alpine uses apk)
RUN apk add --no-cache nodejs npm curl

# Pre-install the Check Point MCP server
RUN npm install -g @chkp/quantum-management-mcp

ENTRYPOINT ["catatonit", "--", "mcp-proxy"]
