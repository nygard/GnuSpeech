#!/usr/bin/python

import getopt, re, string, sys

class Usage(Exception):
      def __init__(self, msg):
            self.msg = msg

def usage():
      print "dict.py 1.0 (2004-04-20)"
      print "Usage: dict.py [-c] [-v] <dictionary>"
      print

info_map = {'a': 'Noun',
            'b': 'Verb',
            'c': 'Adjective',
            'd': 'Adverb',
            'e': 'Pronoun',
            'f': 'Article',
            'g': 'Preposition',
            'h': 'Conjunction',
            'i': 'Interjection',
            'j': '???',
            'k': 'Proper Name',
            'l': 'Location Name',
            'm': 'Concept Name',
            }

dict = {}

def decode_info(info):
      if not info: return ''
      types = []
      for c in info[:]:
            try:
                  types.append(info_map[c])
            except:
                  print "Unknown key", c, "in string", info
      return string.join(types, ', ')

def findword(w):
      try:
            pron = dict[w]
      except KeyError:
            pron = None
      return pron

def lookup():
      print "> ",
#      str = string.rstrip(sys.stdin.readline())
      str = sys.stdin.readline().rstrip()
      while str:
            print "Str: ", str
#            words = [string.lower(x) for x in re.split('\s+', str)]
            words = [x.lower() for x in re.split('\s+', str)]
#            prons = [dict[w] for w in words]
#            prons = [findword(w) for w in words]
            prons = []
            for w in words:
                  try:
                        prons.append(dict[w])
                  except:
                        pass
            print "Words:", words
            print "Prons:", string.join(prons)
            print "> ",
            str = sys.stdin.readline().rstrip()

def main(argv=None):
      try:
            _main(argv)
      except Usage, err:
            print >>sys.stderr, err.msg
#            print >>sys.stderr, "for help use --help"
            print >>sys.stderr
            usage()
            return 2

def _main(argv=None):
      if argv == None:
            argv = sys.argv

      verbose = False
      clean = False
      test = False

      try:
            opts, args = getopt.getopt(argv[1:], "cvt")
      except getopt.error, msg:
            raise Usage(msg)

      for o, a in opts:
            if o == "-c":
                  clean = True
            if o == "-t":
                  test = True
            if o == "-v":
                  verbose = True

      if len(args) < 1:
            raise Usage('Error: Must specify filename')

      f = open(args[0], 'r')

      copyright = f.readline();
      if clean or verbose:
            print copyright,

      trans = string.maketrans(' ', '_')

      line = f.readline()
      while line:
            line = line.rstrip()
            key, value = re.split('\s+', line, 1)
            m = re.match('(.+)/(.*)', key)
            if m:
                  word = m.group(1)
                  pos = m.group(2)
            else:
                  word = key
                  pos = None

            value = string.translate(value, trans)
            m = re.match('(.+)%(.+)', value)
            if m:
                  pron = m.group(1)
                  info = m.group(2)
            else:
                  pron = value
                  info = None

            if verbose:
                  if not pos: pos = '-'
                  print "%-30s %-5s %-70s %s" % (word, pos, pron, decode_info(info))
            elif clean:
                  print key, value
            elif test:
                  dict[key] = pron

            line = f.readline()

      f.close()

      if test:
            lookup()

if __name__ == '__main__':
      sys.exit(main())
