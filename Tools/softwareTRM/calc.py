#!/usr/bin/python

def speedOfSound(temperature):
    """Calculate speed of sond according to the temperature (in Celsius)."""
    return 331.4 + (0.6 * temperature)

c = speedOfSound(25)
controlRate = 250

def doit(sectionCount, tubeLength):
    """Calculate tube parameters."""
    # // is floor division, introduced in Python 2.2 <http://www.python.org/doc/2.2.3/whatsnew/node7.html>
    controlPeriod = c * sectionCount * 100 // (tubeLength * controlRate)
    sampleRate = controlRate * controlPeriod
    actualTubeLength = c * sectionCount * 100.0 / sampleRate
    print "Sections: %d, length: %.2f, control period: %d, sample rate: %d, actual tube length: %.4f" % (sectionCount, tubeLength, controlPeriod, sampleRate, actualTubeLength)

for sections in [10, 30]:
    for length in [20, 17.5, 12, 10]:
        doit(sections, length)

#doit(10, 17.5)
