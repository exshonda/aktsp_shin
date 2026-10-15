
debugger.Connect()
if debugger.Download.LoadModule(r"OBJECT_FILE_PATH") is True:
    debugger.Reset()
    
    debugger.Breakpoint.Delete()
    
    # use for force merge test (if "AktspInfiniteLoop" is not exist, no problem although display warning)
    Condition = BreakCondition()
    Condition.Address = "AktspInfiniteLoop"
    breakNumber = debugger.Breakpoint.Set(Condition)
    
    Condition = BreakCondition()
    Condition.Address = "infinite_loop"
    breakNumber = debugger.Breakpoint.Set(Condition)
    
    debugger.Breakpoint.Information()
    
    debugger.Go(GoOption.WaitBreak)
    
    debugger.Stop()
debugger.Disconnect()
CubeSuiteExit()
CubeSuiteExit()
CubeSuiteExit()
