#!/usr/bin/env bash
# Резервная копия базы накладных и фотоархива: дамп PostgreSQL + архив фото + архив настроек. Правило 3-2-1: 3 копии, 2 носителя, 1 вне сервера.
# Не удаляйте оригиналы, пока восстановление не проверено.
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] || { echo "нет файла .env рядом со скриптом"; exit 1; }
set -a; . ./.env; set +a
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="${BACKUP_DIR:-./backups}"
mkdir -p "$OUT"
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" | gzip > "$OUT/db_${STAMP}.sql.gz"
docker compose exec -T n8n tar czf - -C / photos > "$OUT/photos_${STAMP}.tar.gz"
tar czf "$OUT/config_${STAMP}.tar.gz" .env docker-compose.yml init.sql
ls -lh "$OUT"/*"${STAMP}"*
echo "Готово. Скопируйте файлы из $OUT на второй носитель и вне сервера, затем проверьте восстановление на тестовой машине."
