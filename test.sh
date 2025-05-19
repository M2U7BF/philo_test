#!/bin/bash

make re
if [ $? -ne 0 ]; then
  exit 1
fi
echo ""

# TODO 許可関数以外を検知するように変えたい
echo "使用関数のチェック -------------------------------------------"
nm -u ./philo | grep GLIBC
echo ""

echo "メイン処理のチェック -------------------------------------------"
valgrind --leak-check=full --show-leak-kinds=all -q ./philo
echo ""
