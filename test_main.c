#include "../philo.h"
#include <stdio.h>

void	put_test_name(char *s)
{
	printf("%s ----------\n", s);
}

void	put_ng(void)
{
	printf("NG🔥\n");
}

void	test_ft_usleep(void)
{
	long long	us;
	long long	start;
	long long	end;
	long long	diff;
  int times; // 繰り返し回数

	put_test_name("test_ft_usleep");
	us = 100000;
  times = 30;
	start = get_ms();
	for (int i = 0; i < times; i++)
  {
		// usleep(us);
		ft_usleep(us);
  }
	end = get_ms();
	diff = end - start;
	if (us / 1000 * times != diff)
	{
    put_ng();
    printf("start: timestamp:%lld, in: %lld(ms)\n", start, us / 1000);
    printf("end: timestamp:%lld\n", end);
    printf("diff: %lld(ms)\n", diff);
	}
	else
	  printf("OK\n");
	printf("\n");
}

int	main(void)
{
	test_ft_usleep();
	return (0);
}
