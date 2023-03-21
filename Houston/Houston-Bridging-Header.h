#import <AppKit/AppKit.h>

typedef unsigned int CGSConnectionID;
typedef unsigned int CGSWorkspaceID;

//CGSConnectionID _CGSDefaultConnection();
CGSConnectionID CGSMainConnectionID();
id CGSCopyManagedDisplaySpaces(CGSConnectionID cid);

//TODO: use it
CGError CGSGetWorkspace(CGSConnectionID cid, CGSWorkspaceID *workspace);
//CGError CGSSetWorkspace(CGSConnectionID cid, CGSWorkspaceID workspace);// there is no such symbol in the newer versions of macOS

AXError _AXUIElementGetWindow(AXUIElementRef elementRef, CGWindowID *wid);
