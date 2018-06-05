About
========
This is a Windows Client for USBIP v2.0. It contains drivers, executables and scripts to install it as a service.

Usage: 
1. Copy it to any folder.
1. Run `install.cmd` with Administrator privileges. 
1. Answer the questions. 
1. Done.

Tested in Windows 8.1 and Windows 10.

Driver
----------

If the script can't install the driver then install in manually: open the folder in Explorer, right-click on `USBIPEnum.inf` and choose 'Install'. 

If this didn't help then do this:
1. Start a the Device Manager
1. Click Any hardware node
1. Choose "Add Legacy Hardware" from the "Action" menu
1. At the 'Welcome to the Add Hardware Wizard', click 'Next'.
1. Select 'Install the hardware that I manually select from the list'
1. click 'Next'
1. Click 'Have Disk', click 'Browse', choose the uncompressed directory, and click OK.
1. Click on the 'USB/IP Enumerator', and then click Next.
1. At 'The wizard is ready to install your hardware', click Next.
1. Click Finish at 'Completing the Add/Remove Hardware Wizard.' 
