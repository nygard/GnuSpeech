#!/usr/bin/python

def speedOfSound(temperature):
    """Calculate speed of sond according to the temperature (in Celsius)."""
    return 331.4 + (0.6 * temperature)

c = speedOfSound(25)
controlRate = 250

def sectionLength(sampleRate):
    """Calculate section length (in cm) of a tube based on the sampling rate.  See PRC page 13."""
    return c / sampleRate * 100

def doit(sectionCount, tubeLength):
    """Calculate tube parameters."""
    # // is floor division, introduced in Python 2.2 <http://www.python.org/doc/2.2.3/whatsnew/node7.html>
    controlPeriod = c * sectionCount * 100 // (tubeLength * controlRate)
    sampleRate = controlRate * controlPeriod
    actualTubeLength = sectionLength(sampleRate) * sectionCount
    print "Sections: %d, length: %.2f, control period: %d, sample rate: %d, actual tube length: %.4f" % (sectionCount, tubeLength, controlPeriod, sampleRate, actualTubeLength)

for sections in [9, 10, 30]:
    for length in [20, 17.5, 14, 12, 10]:
        doit(sections, length)

#doit(10, 17.5)

print "Section length: %f" % sectionLength(19750)
