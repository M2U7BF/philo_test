#!/bin/bash

# テストフラグ
use_func_test=1
norm_test=1
func_test=0
arg_test=1
main_test=1

check_exit_status()
{
  if [ $? -ne $1 ]; then echo "NG🔥"; else echo OK; fi
}

philo()
{
  # -fsanitize=threadフラグを使用する場合は下記で実行する模様。だがうまく動かない（2025/05/22）
  # setarch $(uname -m) -R ./philo ...
  expected_status=$1
  shift 1

  echo "execution: ./philo $@"
  echo ""

  echo "-- リークテスト --"
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo "$@"
  check_exit_status $expected_status
  echo ""

  echo "-- データ競合テスト --"
  valgrind --tool=helgrind -q ./philo "$@"
  check_exit_status $expected_status
  echo ""
}

make fclean
make -n debug
if [ $? -eq 0 ]; then
  rm -f philo.a
  make debug
else
  make
fi
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

if [ $norm_test -eq 1 ]; then
  echo "norminetteのチェック -------------------------------------------"
  norminette
  check_exit_status 0
  echo ""
fi

if [ $func_test -eq 1 ]; then
  echo "メイン以外の基本関数のテスト -------------------------------------------"
  cc -o ./func_test philo_test/test_main.c philo.a && ./func_test
  check_exit_status 0
  echo ""
fi

if [ $arg_test -eq 1 ]; then
  echo "引数エラーのチェック -------------------------------------------"

  # 引数の個数：少ない
  philo 1
  philo 1 a
  philo 1 a a a

  # 引数の個数：多い
  philo 1 1 1 1 1 1 1

  # 引数の値の種類：数値以外
  philo 1 a a a a
  philo 1 a a a a a
  philo 1 1 a a a a
  philo 1 1 1 a a a
  philo 1 1 1 1 a a
  philo 1 1 1 1 1 a

  # 引数の値の種類：小数点
  philo 1 0.321 0.321 0.321 0.321 0.321

  # 引数の値の種類：INT_MAX以上
  philo 1 2147483648 2147483648 2147483648 2147483648 2147483648

  # 引数の値の種類：負数
  philo 1 -1 -1 -1 -1 -1

  echo ""
fi

# TODO メインの処理で、0のとき動くか。ft_atoiに不安あり
if [ $main_test -eq 1 ]; then
  echo "メイン処理のチェック -------------------------------------------"
  # 実行時の構文：
  # ./philo \
  #   number_of_philosophers \
  #   time_to_die \
  #   time_to_eat \
  #   time_to_sleep \
  #   [number_of_times_each_philosopher_must_eat]

  echo "-- number_of_times_each_philosopher_must_eatなし --"
  number_of_philosophers=5
  time_to_die=800
  time_to_eat=200
  time_to_sleep=200
  philo 0 \
    $number_of_philosophers \
    $time_to_die \
    $time_to_eat \
    $time_to_sleep
  echo ""

  echo "-- number_of_times_each_philosopher_must_eatあり --"
  number_of_times_each_philosopher_must_eat=7
  philo 0 \
    $number_of_philosophers \
    $time_to_die \
    $time_to_eat \
    $time_to_sleep \
    $number_of_times_each_philosopher_must_eat
  echo ""
fi
