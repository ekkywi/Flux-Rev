#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Memulai Setup Lingkungan Pengembangan Flux...${NC}"

if [ ! -f .env ]; then
    echo -e "${BLUE}📄 Menyalin .env.example ke .env...${NC}"
    cp .env.example .env
fi

echo -e "${BLUE}🐳 Menyalakan Docker Containers...${NC}"
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build

echo -e "${BLUE}📂 Mengatur perizinan folder storage & cache...${NC}"
sudo chmod -R 777 storage bootstrap/cache

echo -e "${BLUE}📦 Menginstal dependensi Composer...${NC}"
docker exec -it flux_app composer install

echo -e "${BLUE}🔑 Menyiapkan Application Key...${NC}"
docker exec -it flux_app php artisan key:generate

echo -e "${BLUE}🗄️  Menjalankan migrasi database...${NC}"
docker exec -it flux_app php artisan migrate:fresh

echo -e "${BLUE}🌐 Menginstal dependensi NPM...${NC}"
docker exec -it flux_app npm install

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}✅ Flux berhasil disiapkan!${NC}"
echo -e "${GREEN}🌍 Web: http://localhost:8080${NC}"
echo -e "${GREEN}💻 Terminal: docker exec -it flux_app zsh${NC}"
echo -e "${GREEN}==========================================${NC}"