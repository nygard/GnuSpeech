GnuSpeech
=========

Applications
------------

### Monet

The main interactive application that synthesizes speech and allows for
experimentation with many speech parameters and settings.  The actual synthesis
occurs in the framework GnuSpeech.framework.  The articulatory tube model that
is used by GnuSpeech.framework is located in Tube.framework.  Monet now supports
entry of text as punctuated English text instead of the original phoneme string
produced by PreMo.

### Synthesizer

An interactive application that allows a user (usually a language developer or
someone interested in the behaviour of the tube model) to interact directly
with the tube model, listen to the output under different static conditions,
and analyse the output.

### PrEditor

An application that allows users to create and maintain their own dictionaries.
This application is not yet fully functional.

### PreMo

A simple application that allows the user to enter text and convert it into a
special phoneme string which was required for input into an older version of
Monet.  This is now a legacy application as it is no longer required to use
Monet.

### GnuTTSClient

A simple text-to-speech client application that accesses the functionality of the
text-to-speech server (GnuTTSServer) programmatically.


Frameworks
----------

### GnuSpeech.framework

The main framework for all reusable components in the GnuSpeech project.  This
framework should be copied to either /Library/Frameworks or
~/Library/Frameworks.  Assuming /Library/Frameworks as the destination folder,
issue the following commands to install:

    $ sudo cp -rf GnuSpeech.framework /Library/Frameworks
    $ sudo chmod -R go-w /Library/Frameworks/GnuSpeech.framework

### Tube.framework

The underlying articulatory tube resonance model for speech synthesis.  This
framework should be copied to either /Library/Frameworks or
~/Library/Frameworks.  Assuming /Library/Frameworks as the destination folder,
issue the following commands to install:

    $ sudo cp -rf Tube.framework /Library/Frameworks
    $ sudo chmod -R go-w /Library/Frameworks/Tube.framework


Daemons
-------

### GnuTTSServer

This is the GnuSpeech text-to-speech server.  The server is implemented using
the OS X Distributed Objects architecture.  To install the server, build the
GnuTTSServer project, locate the GnuTTSServer executable, diphones.xml,
org.gnu.GnuSpeech.GnuTTSServer.plist file, and then issue the following
commands to install the server and configuration files:

    $ sudo mkdir -p /Library/GnuSpeech
    $ sudo cp GnuTTSServer /Library/GnuSpeech/
    $ sudo cp diphones.xml /Library/GnuSpeech/
    $ sudo cp org.gnu.GnuSpeech.GnuTTSServer.plist /Library/LaunchDaemons/

Now restart your computer.

Alternatively, instead of restarting your computer, you can unload, load, and
restart the server by issuing these commands from the terminal:

    $ sudo launchctl unload /Library/LaunchDaemons/org.gnu.GnuSpeech.GnuTTSServer.plist
    $ sudo launchctl load /Library/LaunchDaemons/org.gnu.GnuSpeech.GnuTTSServer.plist
    $ sudo launchctl start org.gnu.GnuSpeech.GnuTTSServer

Note: All logging for the GnuTTSServer appears in the logfile
/Library/Logs/GnuSpeechDaemon.log and is accessible from the Console.


Services
--------

### GnuSpeechService

A GnuSpeech text-to-speech OS X service that appears in the standard OS X
service menu under the menu title "GnuSpeech".  Build the project, locate the
GnuSpeechService.service bundle, and issue the following commands from the
terminal:

    $ mkdir -p ~/Library/Services
    $ cp -rf GnuSpeechService.service ~/Library/Services
    $ chmod -R go-w ~/Library/Services/GnuSpeechService.service

Alternatively, if you want to install the service for all users on the system
and not just for your own user account, type the following instead:

    $ sudo cp -rf GnuSpeechServices.service /Library/Services
    $ sudo chmod -R go-w /Library/Services/GnuSpeechService.service

Now log out and log back in so that OS X services recognizes the newly
installed service and places a menu item in the Services menu.

Note: If you install the GnuTTSServer and have chosen not to reboot your system
and instead have issued the terminal commands to start the server, make sure
you kill the GnuSpeechService.service process using the
/Applications/Utilities/Activity Monitor.app application (or similar).  When you
invoke the GnuSpeech service for the first time from the Services menu it will
be automatically launched.


Builds
------

This folder contains the beta builds of the GnuSpeech project.  These builds are
disk image files (.dmg) and contain packages that contain all the required
software to run GnuSpeech on OS X.


Installers
----------

This folder contains the OS X Package Maker (.pmdoc) and/or WhiteBox IceBerg
package maker (.packproj) documents that are used to create the package
installer which is placed within a disk image file (.dmg) for distribution.


Other
-----

Legacy folders and documents that are no longer pertinent in the latest version
of the OS X GnuSpeech project but remain for reference purposes only.
