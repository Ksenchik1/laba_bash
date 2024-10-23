#!/bin/bash

#Проверка входных параметров
if [ $# -ne 3 ]; then
        echo "Usage: $0 <path_to_folder> <perce$ntage_threshold> <size_limit_in_bytes"
        exit 1
fi

DIRECTORY=$1
THRESHOLD=$2
SIZE_LIMIT=$3

# Проверка на существование папки
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory $DIRECTORY does not exist."
    exit 1
fi

#Получение информации о заполняемости папки
USAGE=$(df -h "$DIRECTORY" | awk 'NR==2 {print $5}' | sed 's/%//')

#Проверка, превышает ли заполненность заданный порог
if [ $USAGE -gt $THRESHOLD ]; then
        echo "Directory usage ($USAGE%) exceeds threshold ($THRESHOLD%). Archiving files."

        #Поиск и архивирование N самых старых фaйлов
        N=5 #Количество файлов для архивирования
        OLD_FILES=$(ls -t "$DIRECTORY" | tail -n $N)

        #Архивирование файлов
        tar -czf "$DIRECTORY/../backup/backup_$(date +%Ym%d_%H%M%S).tar.gz" -C "$DIRECTORY" $OLD_FILES

        #Удаление заархивированных файлов
        rm "$DIRECTORY"/{$OLD-FILES}
else
        echo "Directory usage ($USAGE%) is below the threshold ($THRESHOLD%). No action taken."
fi


limit_directory_size() {
    local dir=$1
    local limit=$2

    while [ $(du -sb "$dir" | awk '{print $1}') -gt $limit ]; do
        # Удаляем самый старый файл
        OLD_FILE=$(ls -t "$dir" | tail -n 1)
        echo "Removing old file: $OLD_FILE to limit folder size."
        rm "$dir/$OLD_FILE"
    done
}

# Лимитирование размера папки
limit_directory_size "$DIRECTORY" "$SIZE_LIMIT"
