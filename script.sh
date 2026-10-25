#!/usr/bin/env bash
set -Eeuo pipefail

readonly N=10
readonly LOG_FILE="/home/ubuntu/resource-monitor/monitor.log"

trap 'printf "Мониторинг остановлен.\n" >&2; exit 0' INT TERM
trap 'printf "Ошибка: мониторинг прерван (строка %s). Проверьте свободное место и доступ к журналу.\n" "$LINENO" >&2; exit 1' ERR

# Проверяем зависимости до начала бесконечного цикла.
for command_name in date free df uptime sleep mkdir nproc; do
    if ! command -v "$command_name" > /dev/null 2>&1; then
        printf 'Ошибка: не найдена команда %s.\n' "$command_name" >&2
        exit 1
    fi
done

# Создаём каталог и открываем журнал для дописывания.
if ! mkdir -p -- "${LOG_FILE%/*}"; then
    printf 'Ошибка: не удалось создать каталог журнала.\n' >&2
    exit 1
fi
if ! exec 3>> "$LOG_FILE"; then
    printf 'Ошибка: не удалось открыть журнал %s для записи.\n' "$LOG_FILE" >&2
    exit 1
fi

# Сбой одной команды не мешает собрать остальные показатели.
run_command() {
    local status
    printf '\n>>> %s\n' "$*"
    if "$@"; then
        return 0
    else
        status=$?
        printf 'ОШИБКА: команда %s завершилась с кодом %s.\n' "$*" "$status"
        printf 'Ошибка сбора: %s (код %s).\n' "$*" "$status" >&2
    fi
}

printf 'Мониторинг запущен: интервал %s секунд, журнал %s:\n' "$N" "$LOG_FILE"

while true; do
    {
        date '+--- %Y-%m-%d %H:%M:%S ---'
        run_command free -h
        run_command df -h
        run_command uptime
        run_command nproc

        printf '\n>>> /proc/loadavg\n'
        if IFS= read -r load_average < /proc/loadavg; then
            printf '%s\n' "$load_average"
        else
            printf 'ОШИБКА: не удалось прочитать /proc/loadavg.\n'
            printf 'Ошибка сбора: не удалось прочитать /proc/loadavg.\n' >&2
        fi
        printf '\n'
    } >&3

    sleep "$N"

done
