class Spaces {
    static func focusPrevSpace() {
        let cid = CGSMainConnectionID()
        var wid = CGSWorkspaceID(0)
        CGSGetWorkspace(cid, &wid)
        debugPrint("workspace", wid)
//        scripting_addition_focus_space(wid - 1)
    }
    
    static func focusNextSpace() {
        let cid = CGSMainConnectionID()
        var wid = CGSWorkspaceID(0)
        CGSGetWorkspace(cid, &wid)
        debugPrint("workspace", wid)
//        scripting_addition_focus_space(wid + 1)
    }
    
    
    //TODO: it's from yabai
//    bool scripting_addition_focus_space(uint64_t sid)
//    {
//        char bytes[0x100];
//
//        char length = 2;
//        pack(bytes, sid, length);
//        bytes[1] = 0x01;
//        bytes[0] = length-1;
//
//        return scripting_addition_send_bytes(bytes, length);
//    }
}
