#include <stdio.h>

#define BETA                      5.658        /*  kaiser window parameters  */
#define IzeroEPSILON              1E-21

//
// function:	Izero
//
//	purpose:	Returns the value for the modified Bessel function of
//                      the first kind, order 0, as a double.
//
//      reference:      <http://en.wikipedia.org/wiki/Bessel_function>
//                      <http://mathworld.wolfram.com/ModifiedBesselFunctionoftheFirstKind.html>
//

double Izero(double x)
{
    double sum, u, halfx, temp, n;

    n = 1.0;
    sum = u = 1;
    halfx = x / 2.0;

    do {
	temp = halfx / n;
	n += 1.0;
	temp *= temp;
	u *= temp;
	sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return sum;
}

// This computes the sum of (A^k)/((k!)^2), where A = (1/4)x^2, k = 0, 1, 2, ...

double myIzero(double x)
{
    double sum, A, Ak, k, denominator, u;

    Ak = A = x * x / 4.0;
    k = 2.0;
    denominator = 1.0;
    sum = 1.0 + A;

    do {
        Ak *= A;
        denominator *= k * k;
        k += 1.0;
        u = Ak / denominator;
        sum += u;
    } while (u >= (IzeroEPSILON * sum));

    return sum;
}

int main(int argc, char *argv[])
{
    unsigned int index;

    printf("Izero(BETA) = Izero(%g) = %g\n", BETA, Izero(BETA));
    printf("myIzero(%g) = %g\n", BETA, myIzero(BETA));
    for (index = 0; index < 10000000; index++) {
        //Izero(BETA);
        myIzero(BETA);
    }

    return 0;
}
