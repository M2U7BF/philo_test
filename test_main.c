#include "../philo.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void	put_test_name(char *s)
{
	printf("%s ----------\n", s);
}

void	put_ng(void)
{
	printf("NG🔥\n");
}

void	test_ft_atoi_2(void)
{
	int			error;
	int			is_error;
	static char	*in[] = {"123", "1.23", "aa", "2147483647", "999999999999999999999999", "-2147483648",
			"2147483648", "-2147483649"};
	static int	expected[] = {123, 1, 0, 2147483647, -1, -2147483648, -2147483648,
			2147483647};
	int			result;

	put_test_name("test_ft_atoi_2");
	is_error = 0;
	error = 0;
	for (int i = 0; i < 7; i++)
	{
		result = ft_atoi_2(in[i], &error);
		if (result != expected[i])
		{
			put_ng();
			printf("in:%s\n", in[i]);
			printf("expected:%d\n", expected[i]);
			printf("本家:%d\n", atoi(in[i]));
			printf("result:%d\n", result);
			printf("\n");
			is_error = 1;
		}
	}
	if (!is_error)
		printf("OK\n");
	printf("\n");
}

void	test_ft_usleep(void)
{
	long long	us;
	long long	start;
	long long	end;
	long long	diff;

	put_test_name("test_ft_usleep");
	int times; // 繰り返し回数
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
	test_ft_atoi_2();
	test_ft_usleep();
	return (0);
}
