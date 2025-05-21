#!/bin/bash

# テストフラグ
use_func_test=1
norm_test=1
arg_test=0
main_test=1

check_exit_status()
{
  if [ $? -ne $1 ]; then echo "NG🔥"; else echo OK; fi
}

philo()
{
  # -fsanitize=threadフラグを使用する場合は下記で実行する模様。だがうまく動かない（2025/05/22）
  # setarch $(uname -m) -R ./philo ...

  echo "リークテスト"
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo "$@"
  echo ""

  echo "データ競合テスト"
  valgrind --tool=helgrind ./philo "$@"
  echo ""
}

make fclean
make debug
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

if [ $arg_test -eq 1 ]; then
  echo "引数エラーのチェック -------------------------------------------"

  # 引数の個数：少ない
  philo
  check_exit_status 1

  philo a
  check_exit_status 1

  philo a a a
  check_exit_status 1

  # 引数の個数：多い
  philo 1 1 1 1 1 1
  check_exit_status 1

  # 引数の値の種類：数値以外
  philo a a a a
  check_exit_status 1

  philo a a a a a
  check_exit_status 1

  philo 1 a a a a
  check_exit_status 1
  philo 1 1 a a a
  check_exit_status 1
  philo 1 1 1 a a
  check_exit_status 1
  philo 1 1 1 1 a
  check_exit_status 1

  # 引数の値の種類：小数点
  philo 0.321 0.321 0.321 0.321 0.321
  check_exit_status 1

  # 引数の値の種類：INT_MAX以上
  philo 2147483648 2147483648 2147483648 2147483648 2147483648
  check_exit_status 1

  # 引数の値の種類：負数
  philo -1 -1 -1 -1 -1
  check_exit_status 1

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
  philo \
    $number_of_philosophers \
    $time_to_die \
    $time_to_eat \
    $time_to_sleep
  check_exit_status 0
  echo ""

  echo "-- number_of_times_each_philosopher_must_eatあり --"
  number_of_times_each_philosopher_must_eat=7
  philo \
    $number_of_philosophers \
    $time_to_die \
    $time_to_eat \
    $time_to_sleep \
    $number_of_times_each_philosopher_must_eat
  check_exit_status 0
  echo ""
fi
