Wiki About The Rutgers App

Prerequisite :
        Read apple docs on UITableView
        Watch Advanced Collection View Applications Lecture.


Each of the "content sources" has a seperate channel :
There are of three main types :
1) Custom Channels : eg : BUS , SOC etc ( In the folder structure they are placed outside the common folder in the Rutgers root folder)
        Seperate View Controllers Data Sources and Loading managers are created for them .
2) Reader :
3) DTables :
        Dtables represent the tree structure of a particular channel like atheletics : That is from the athelitcs we can go to the scheldules , direction news etc.
        The reader represent the leaves of this tree. In the leaves we display data in a particular format which can be customized
4) WebViews :
        It is just a web view controller which points to a particular url that we set.

    The mapping between a channel and its view is done by using the ordered_content file and the RUChannelManager class. Ordered content has a mapping between each channel and
    the view controller that is used to display the data. Each channel has an object called handle which decides the view controller that will be used to display the channel
    Each class has  a load method this is called by the objective c runtime and within the load method , register class method is called. With in this register class method we
    decide what the type of the view controller is , that this class sets up the handle for the view controller.

    So using the handle we can decide which view controller we have to call when a user touches on the screen


TableViewController and DataSource
    These are the super classes which are subclassed for the creation of most of the app.


> ScarletNight :
            A Dynamics Table View Controller :
            End Nodes are RUReaderViewController


> App Transport Security.
    Apple for ios 9 and higher needs both https and the ssl version of the server to be lastest.
    For the rumobile.rutgers.edu these conditions are satisfied
    But for the next bus api , which does not even have an https api
        and for the soc api , which does not have the latest SSL version
        we add exception in the Rutgers info plist.
    Final solution is to allow the app to connect to any server , even without ssl encryption .

> For the Web View Controllers , we use an external library for ios 7 called TOWebViewController. This should be kept on version 2.0.14. Updating to higher versions causes clashes with both libraries that can be used within our app to
    create the slide view controllers on the left side of the screen.


> We have two classes called MMD and SK drawer view controllers. They are open source libraries and these libraries are used to set up the drawer. We are currently using the SK drawer view controller , to prevent gesture recognizer issue that occurs when using the edit channels view controller with the drawer.
    But the issue with SK drawer class is that the gestures are more difficult to pass on , and we might decide to disable the swipe left and right feature in the tab view controllers


> Info about MapsViewController :
        We have added a MapBox Framework to the app , but we are removing it for 4.1 . It will be added back later when we are using OSM data.
        > Keep in mind that the RUMapsViewController file ( not in xcode but in folder ) is not used as the maps view controller , but the MapsViewController.swift file is.



> TEST SEQUENCE BEFORE RELEASE 
    > Run on all emulators ios 7 - ios 10 
                > Do not skip minor releases 
                > Spend 5 minutes testing on each of the devices 
    > Run on all physical devices 



