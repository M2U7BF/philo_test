#!/bin/bash

# 変数
count=0

# 定数
OK="OK💎"
NG="NG🔥"


increment_and_print() {
    ((count++))
    echo "[$count]-----------------------------------------------------------------"
}

check_exit_status()
{
  if [ $? -ne $1 ]; then echo "exit: $NG"; else echo "exit: $OK"; fi
}

make_mandatory() {
  echo "make fclean"
  make fclean >/dev/null
  make -n debug >/dev/null 2>&-
  if [ $? -eq 0 ]; then
    echo "make debug"
    make debug >/dev/null
  else
    echo "make"
    make >/dev/null
  fi
  if [ $? -ne 0 ]; then
    exit 1
  fi
  echo ""
}

make_bonus() {
  echo "make fclean"
  make fclean >/dev/null
  echo "make -n debug_bonus"
  make -n debug_bonus >/dev/null
  if [ $? -eq 0 ]; then
    echo "make debug_bonus"
    make debug_bonus >/dev/null
  else
    echo "make bonus"
    make bonus >/dev/null
  fi
  if [ $? -ne 0 ]; then
    exit 1
  fi
  echo ""
}

put_test_name() {
  printf "========== 【%s】==========\n" $1
}

put_test_pattern() {
  printf -- "---- %s\n" $1
}

extract_valgrind_blocks_by_keyword() {
    local log_file="$1"
    local keyword="$2"  # e.g., "Invalid free", "definitely lost"
    local line block=""
    local in_block=false

    # 結果を格納する配列（グローバル変数）
    VALGRIND_BLOCKS=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^==[0-9]+==.*$keyword ]]; then
            if $in_block && [[ -n "$block" ]]; then
                VALGRIND_BLOCKS+=("$block")
                block=""
            fi
            in_block=true
        fi

        if $in_block; then
            block+="$line"$'\n'
        fi

        if $in_block && [[ "$line" =~ ^==[0-9]+==\ *$ ]]; then
            VALGRIND_BLOCKS+=("$block")
            block=""
            in_block=false
        fi
    done < "$log_file"

    if $in_block && [[ -n "$block" ]]; then
        VALGRIND_BLOCKS+=("$block")
    fi
}
