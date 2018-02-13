#include <stdint.h>

typedef struct int64 int64;

unsigned long m;

unsigned long Random() 
{
	m = 1664525 * m + 1013904223;
	return m;
}

struct int64
{
	int32_t lo32;
	int32_t hi32;
};

void add_64(int64 *result, int64 *oper1, int64 *oper2)
{
	result->lo32 = oper1->lo32 + oper2->lo32;
	result->hi32 = oper1->hi32 + oper2->hi32;
	if(result->lo32 < oper1->lo32)
		++result->hi32;
}

int main()
{
	int64 result, oper1, oper2;
	oper1.lo32 = Random();
	oper1.hi32 = Random();
	oper2.lo32 = Random();
	oper2.hi32 = Random();
	add_64(&result, &oper1, &oper2);
}