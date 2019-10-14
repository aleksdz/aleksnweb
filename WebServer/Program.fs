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
                        Filters.path "/" >=> (Redirection.redirect "https://github.com/zaersx/")
                        Files.browseHome
                        RequestErrors.NOT_FOUND "Page not found." 
                    ]
            ]

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
                    homeFolder = Some (Path.GetFullPath "../../../Views")
            }
            app
        0
