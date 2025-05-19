#!/bin/bash

# テストフラグ
use_func_test=1
arg_test=1
main_test=1

check_exit_status()
{
  if [ $? -ne $1 ]; then echo NG; else echo OK; fi
}

make re
if [ $? -ne 0 ]; then
  exit 1
fi
echo ""

if [ $use_func_test -eq 1 ]; then
  echo "使用関数のチェック -------------------------------------------"
  nm -u ./philo | grep GLIBC | grep -v -E '__libc_start_main|memset|printf|malloc|free|write|usleep|gettimeofday|pthread_create|pthread_detach|pthread_join|pthread_mutex_init|pthread_mutex_destroy|pthread_mutex_lock|pthread_mutex_unlock'
  check_exit_status 1
  echo ""
fi

if [ $arg_test -eq 1 ]; then
  echo "引数エラーのチェック -------------------------------------------"

  # 引数の個数：少ない
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo
  check_exit_status 1

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a
  check_exit_status 1

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a
  check_exit_status 1

  # 引数の個数：多い
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 1 1 1 1 1
  check_exit_status 1

  # 引数の値の種類：数値以外
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a a
  check_exit_status 1

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo a a a a a
  check_exit_status 1

  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 a a a a
  check_exit_status 1
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 1 a a a
  check_exit_status 1
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 1 1 a a
  check_exit_status 1
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 1 1 1 1 a
  check_exit_status 1

  # 引数の値の種類：小数点
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 0.321 0.321 0.321 0.321 0.321
  check_exit_status 1

  # 引数の値の種類：INT_MAX以上
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo 2147483648 2147483648 2147483648 2147483648 2147483648
  check_exit_status 1

  # 引数の値の種類：負数
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo -1 -1 -1 -1 -1
  check_exit_status 1

  echo ""
fi

# メインの処理で、0のとき動くか。ft_atoiに不安あり
if [ $main_test -eq 1 ]; then
  echo "メイン処理のチェック -------------------------------------------"
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo
  echo ""
fi
