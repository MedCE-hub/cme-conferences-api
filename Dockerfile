FROM node:22-alpine
LABEL io.modelcontextprotocol.server.name="io.github.MedCE-hub/cme-conferences-api"
LABEL org.opencontainers.image.source="https://github.com/MedCE-hub/cme-conferences-api"
LABEL org.opencontainers.image.description="MCP server for US CME conferences and CE / CME requirements by state (MedCE Hub)"
LABEL org.opencontainers.image.licenses="MIT"
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY src ./src
USER node
ENTRYPOINT ["node", "src/server.js"]
