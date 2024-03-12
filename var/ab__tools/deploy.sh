#!/bin/bash
set -e

DIR_NAME=$(dirname "$(readlink -f "$0")")
cd $DIR_NAME

BRANCH_NAME="$1"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Function to prepend date and time
prepend_datetime() {
    while IFS= read -r line; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') $line"
    done
}
# Перенаправляємо весь вивід в лог файл і консоль
exec 3>&1 > >(prepend_datetime | tee -a "$DIR_NAME"/logs/log.log) 2>&1

echo "-----------------------------------------"

source $DIR_NAME/config/deploy_config.conf
if [ "$CURRENT_BRANCH" != "$main_branch_name" ]; then
      echo "Основна вітка відрізняється від вказаної в налаштуваннях."
      exit 1
fi

# Перевіряємо чи передали ім'я вітки і чи воно не таке саме, як в головної
if [ -z "$BRANCH_NAME" ] || [ "$BRANCH_NAME" = "$main_branch_name" ]; then
      echo "Пуста назва гілки або назва гілки співпадає з назвою головної гілки"
      exit 1
fi

# перевірити чи таку вітку вже мерджили
MERGE_COMMITS_COUNT=$(git log --pretty=format:'%B'|grep -c "branch '$BRANCH_NAME'" || true)

if [ "$MERGE_COMMITS_COUNT" -gt 0 ]; then
      echo "Вітка $BRANCH_NAME попередньо вливалася в $main_branch_name. Дозволено вливати вітку тільки один раз!"
      exit 1
fi


#відключаємо фаст форвард для збереження імені вітки в історії, вливаємо вітку в актуальну версію продакшн і відправляємо в репозиторій
git config --global merge.ff no
git config --global merge.commit no

echo "Видаляємо існуючу вітку перед зливанням"
git branch -D "$BRANCH_NAME" || true 2>/dev/null

echo "Отримуємо зміни по вказаній вітці"
git fetch "$origin_name" "$BRANCH_NAME":"$BRANCH_NAME" || (echo "Помилка. Не вдалося отримати віддалену вітку $BRANCH_NAME" && false)

#Отримуємо файл з діями, щоб можна було запустити перед накладанням даних з коміту
git reset --mixed FETCH_HEAD && (git checkout -- "branches/$BRANCH_NAME/*" || true)

echo "Запуск дій pre_actions для вітки $BRANCH_NAME"
$php_executable $DIR_NAME/deploy.php "$BRANCH_NAME" pre_actions "$php_executable"

git pull "$origin_name" "$BRANCH_NAME" --no-edit
git merge "$BRANCH_NAME" --no-edit && git reset --hard

git push "$origin_name" "$CURRENT_BRANCH"

echo "Запуск дій post_actions для вітки $BRANCH_NAME"
$php_executable $DIR_NAME/deploy.php "$BRANCH_NAME" post_actions "$php_executable"


# Закриваємо файлові дескриптори після завершення
exec >&3 3>&-
