module WebServer =
    open System
    open System.IO
    open Suave
    open Suave.Operators

    let app = 
        choose 
            [
                Filters.GET >=> choose
                    [
                        Filters.path "/" >=> (Successful.OK "My main Page")
                        Files.browseHome
                        RequestErrors.NOT_FOUND "Page not found." 
                    ]
            ]

    let webBindings = 
        [
            HttpBinding.createSimple HTTP "0.0.0.0" 80
        ]
    
    [<EntryPoint>]
    let main _ =
        startWebServer 
            {
                defaultConfig with
                    bindings = webBindings   
                    homeFolder = Some (Path.GetFullPath "../../../Views")
            }
            app
        0