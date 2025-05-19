#!/bin/bash

# テストフラグ
use_func_test=1
arg_test=1
main_test=1

make re
if [ $? -ne 0 ]; then
  exit 1
fi
echo ""

if [ $use_func_test -eq 1 ]; then
  echo "使用関数のチェック -------------------------------------------"
  nm -u ./philo | grep GLIBC | grep -v -E '__libc_start_main|memset|printf|malloc|free|write|usleep|gettimeofday|pthread_create|pthread_detach|pthread_join|pthread_mutex_init|pthread_mutex_destroy|pthread_mutex_lock|pthread_mutex_unlock'
  if [ $? -eq 1 ]; then
    echo "OK"
  fi
  echo ""
fi

if [ $arg_test -eq 1 ]; then
  echo "引数エラーのチェック -------------------------------------------"
  # number_of_philosophers
  # time_to_die
  # time_to_eat
  # time_to_sleep
  # [number_of_times_each_philosopher_must_eat]

  # 引数の個数：少ない
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo
  if [ $? -ne 1 ]; then echo NG; fi

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a
  if [ $? -ne 1 ]; then echo NG; fi

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a
  if [ $? -ne 1 ]; then echo NG; fi

  # 引数の個数：多い
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 1 1 1 1 1
  if [ $? -ne 1 ]; then echo NG; fi

  # 引数の値の種類：数値以外
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a a
  if [ $? -ne 1 ]; then echo NG; fi

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a a a
  if [ $? -ne 1 ]; then echo NG; fi

  # 引数の値の種類：INT_MAX以上
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 2147483648 2147483648 2147483648 2147483648 2147483648
  if [ $? -ne 1 ]; then echo NG; fi

  # 引数の値の種類：負数
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo -1 -1 -1 -1 -1
  if [ $? -ne 1 ]; then echo NG; fi

  echo ""
fi

if [ $main_test -eq 1 ]; then
  echo "メイン処理のチェック -------------------------------------------"
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo
  echo ""
fi
