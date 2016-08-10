Wiki About The Rutgers App

> ScarletNight :
            ( JUNE 28TH )
            A Dynamics Table View Controller :
            End Nodes are RUReaderViewController


> App Transport Security.
    Apple for ios 9 and higher needs both https and the ssl version of the server to be lastest.
    For the rumobile.rutgers.edu these conditions are satisfied
    But for the next bus api , which does not even have an https api
        and for the soc api , which does not have the latest SSL version
        we add exception in the Rutgers info plist.


> For the Web View Controllers , we use an external library for ios 7 called TOWebViewController. This should be kept on version 2.0.14. Updating to higher versions causes clashes with both libraries that can be used within our app to
    create the slide view controllers on the left side of the screen.



