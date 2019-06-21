module WebServer =
    open System
    open Suave
    
    let webBindings = 
        [
            HttpBinding.createSimple HTTP "0.0.0.0" 80
            HttpBinding.createSimple (HTTPS ()) "0.0.0.0" 443
        ]
    
    [<EntryPoint>]
    let main _ =
        startWebServer 
            {
                defaultConfig with
                    bindings = webBindings                
            }
            (Successful.OK "Hello World!")
        0