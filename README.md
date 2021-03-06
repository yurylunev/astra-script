# astra-script
## *Yet Another Astra Linux Automatisation*

Скрипт автоматического создания пользователей в ОС Astra Linux.
В качестве параметра нужно передать путь к файлу с пользователями, который представляет собой текстовый файл с именами пользователей и уровнями доступа. Каждая строка описывает одного пользователя. Уровень доступа задаётся цифрами от 0 до 3, которые обозначают максимальный уровень доступа, где 0 - несекретно, 3 - СС. Имя пользователя и уровень доступа отделяются запятой.
Скрипт позволяет:
- Автоматически создать пользователей в системе и назначить им соответствующий уровень доступа.
- Создать специальную папку с документами в которой предлагается сохранять документы. Каждому пользователю создаются собственные папки, согласно его уровня доступа и папки для обмена файлами.
- Настроить переменную umask для корректной работы пользователей в папках для обмена.
- Настроить LibreOffice для работы в созданной папке по умолчанию.

Синтаксис:
```sh
a-script.sh <база данных пользователей с уровнем доступа>
```
Скрипт необходимо выполнять с правами суперпользователя

```sh
# cd astra-script
# chmod u+x a-script.sh
# ./a-script.sh users
```

Важно: название папки указывается без /

Содержимое файла *profile* заменит файл */etc/profile* (необходимо для установления umask 007).
Содержимое папки config будет перенесено в .config папки пользователя.