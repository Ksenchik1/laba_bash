#!/bin/bash

#удаление предыдущих тестов
rm -rf ~/script_work/10g/*
rm -rf ~/script_work/backup/*

# Функция для создания тестовых данных
create_test_data() {
    for i in {1..10}; do
        dd if=/dev/zero of=~/script_work/10g/file$i.txt bs=1M count=100
    done
}

# Функция для тестирования основного скрипта
run_test() {
    local threshold=$1
    local expect_archived_files=$2
    local log_dir=~/script_work/log

    # Запуск скрипта
    ~/script_work/backup.sh ~/script_work/10g $threshold

    # Проверка результата
    local archived_files_count=$(ls ~/script_work/backup | wc -l)
    limit_folder_size "$log_dir" 512  # Минимум 0.5 GB

    if [ "$archived_files_count" -ge "$expect_archived_files" ] && [ $? -eq 0 ]; then
        echo "Test with threshold $threshold passed: $archived_files_count files were archived."
    else
        echo "Test with threshold $threshold failed. Expected at least $expect_archived_files archived >    fi
}

# Тесты
run_test 70 1  # Ожидаем 1 архивированный файл
run_test 80 0  # Ожидаем 0 архивированных файлов
run_test 85 0  # Ожидаем 0 архивированных файлов
run_test 60 2  # Ожидаем 2 архивированных файла

echo "All tests completed."
