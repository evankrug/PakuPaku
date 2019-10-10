------------------------------------------------------
SETUP TOMCAT 9.0.26 IN INTELIJ IDEA ON LAB COMPUTERS   !! RECOMMENDED !!
------------------------------------------------------

/*** IF AT ANY TIME YOU ARE PROMPTED TO ADD A FIREWALL EXCEPTION, UNSELECT ALL AND CLICK CANCEL. IT WILL STILL WORK ***/

    + Open IntelliJ IDEA on computer (located in c:\IntelliJ\bin\idea64.exe)
    + Open project located in src/new directory
    + Got to File > Settings > Build, Execution, Deployment > Application Servers
    + Click the ' + ' button and select 'Tomcat Server' from the dropdown
    + Set the 'Tomcat Home' field to be reengineering\src\new\tomcat9
    + Make sure the libraries section has 'jsp-api.jar' and 'servlet-api.jar'
    
    + Go to File > Project Structure > Project. Make sure '1.8' is selected under 'Project SDK'
    + Go to > Modules. Select PakuPaku. Make sure Module SDK is '1.8'. If there is an existing Tomcat instance that is red, remove it.
    + Click '+' > 'Jar or Directories' and in the popup select apache-tomcat-9.0.26-windows-x64.zip and click 'OK'
    + Click 'OK' at the bottom of the popup windows


    + Click 'Add Configuration' on the top bar, next to the green build hammer
    + Click ' + ', select Tomcat Server > Local from the popup
    + Rename the instance to 'PakuPaku'
    + Check that HTTP port is 8080.
    + Set 'On Update action' to 'Update Resources' and uncheck the 'Show dialog' box
    + Go to the 'Deployment' tab. Click ' + ' and select artifact from the dropdown menu
    + Select PakuPaku_WAR_Exploded. Set 'Application context' to /pakupaku
    + Click 'OK'
    
    + Click the green run arrow on the top toolbar.


-----------------------------------------------------
SETUP TOMCAT 9.0.26 IN NETBEANS 8.1 ON LAB COMPUTERS
-----------------------------------------------------

    The Install of Netbeans 8.1 on lab computers does not have support for Java EE, which is required to add application servers.
    Development will be mostly fine in Nebeans, however, you will not be able to run the project.
    
