#!/bin/bash

# テストフラグ
use_func_test=1
norm_test=1
func_test=0
arg_test=0
main_test=0
tester_test=0
tester_test2=1

check_exit_status()
{
  if [ $? -ne $1 ]; then echo "exit: NG🔥"; else echo "exit: OK"; fi
}

philo()
{
  # -fsanitize=threadフラグを使用する場合は下記で実行する模様。だがうまく動かない（2025/05/22）
  # setarch $(uname -m) -R ./philo ...
  expected_status=$1
  shift 1

  echo "execution: ./philo $@"
  echo ""

  echo "-- 通常実行 --"
  ./philo "$@"
  check_exit_status $expected_status
  echo ""

  echo "-- リークテスト --"
  # setarch $(uname -m) -R 
  valgrind --leak-check=full --show-leak-kinds=all -q ./philo "$@"
  check_exit_status $expected_status
  echo ""

  echo "-- データ競合テスト --"
  # setarch $(uname -m) -R 
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
  find -maxdepth 1 -name "*.c" | xargs norminette
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
  philo 0 0.321 0.321 0.321 0.321 0.321

  # 引数の値の種類：INT_MAX以上
  philo 1 2147483648 2147483648 2147483648 2147483648 2147483648

  # 引数の値の種類：負数
  philo 1 -1 -1 -1 -1 -1

  echo ""
fi

if [ $main_test -eq 1 ]; then
  echo "メイン処理のチェック -------------------------------------------"
  # 実行時の構文：
  # ./philo \
  #   number_of_philosophers \
  #   time_to_die \
  #   time_to_eat \
  #   time_to_sleep \
  #   [number_of_times_each_philosopher_must_eat]

  # echo "-- number_of_times_each_philosopher_must_eatなし --"
  number_of_philosophers=5
  time_to_die=800
  time_to_eat=200
  time_to_sleep=200
  # philo 0 \
  #   $number_of_philosophers \
  #   $time_to_die \
  #   $time_to_eat \
  #   $time_to_sleep
  # echo ""

  echo "-- number_of_times_each_philosopher_must_eatあり --"
  number_of_times_each_philosopher_must_eat=3
  philo 0 \
    $number_of_philosophers \
    $time_to_die \
    $time_to_eat \
    $time_to_sleep \
    $number_of_times_each_philosopher_must_eat
  echo ""
fi

if [ $tester_test -eq 1 ]; then
  echo "テスターのテスト -------------------------------------------"
  test -d philosophers_tester || git clone https://github.com/AntonioSebastiaoPedro/philosophers_tester.git
  philosophers_tester/philo_tester.sh -a
  philosophers_tester/philo_tester.sh -d
  philosophers_tester/philo_tester.sh -l
fi

if [ $tester_test2 -eq 1 ]; then
  echo "テスター2のテスト -------------------------------------------"
  test -d LazyPhilosophersTester || git clone https://github.com/MichelleJiam/LazyPhilosophersTester.git
  cd LazyPhilosophersTester
  ./test.sh ../philo
  cd -
fi
