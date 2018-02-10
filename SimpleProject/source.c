volatile unsigned long m;

unsigned long Random(void) 
{
	m = 1664525 * m + 1013904223;
	return m;
}
