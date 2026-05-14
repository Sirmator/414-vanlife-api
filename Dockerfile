# ─────────────────────────────────────────
# Étape 1 : Build TypeScript → JavaScript
# ─────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copier les fichiers de dépendances (cache Docker)
COPY package*.json ./
RUN npm ci

# Copier le code source
COPY . .

# Compiler le TypeScript
RUN npm run build

# ─────────────────────────────────────────
# Étape 2 : Image de production (légère)
# ─────────────────────────────────────────
FROM node:20-alpine AS production

WORKDIR /app

# Copier uniquement les dépendances de production
COPY package*.json ./
RUN npm ci --omit=dev

# Copier le code compilé depuis le builder
COPY --from=builder /app/dist ./dist

EXPOSE 3000

# Démarrer l'API NestJS compilée
CMD ["node", "dist/main"]
