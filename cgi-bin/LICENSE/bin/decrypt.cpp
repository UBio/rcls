#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
  const char *const pass = argv[1];

  char *result;
  int ok;
  result = crypt(argv[2], pass);

  ok = strcmp (result, pass) == 0;

  puts(ok ? "1" : "0");
  return ok ? 0 : 1;
}
