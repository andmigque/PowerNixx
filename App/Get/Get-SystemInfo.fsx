open System
open System.Runtime.InteropServices

// Type definition for system information
type SystemInfo = {
    Version: string
    Architecture: string
}

// Function to get system information
let getSystemInfo() = 
    try
        // Create record with system information
        let info = {
            Version = Environment.OSVersion.VersionString
            Architecture = RuntimeInformation.OSArchitecture.ToString()
        }
        
        // Print formatted output
        printfn "\nSystem Information:"
        printfn "---------------------"
        printfn "Version:      %s" info.Version
        printfn "Architecture: %s" info.Architecture
        
        Ok(info)
    with
    | ex -> Error(sprintf "Failed to retrieve system information. Error: %s" ex.Message)

// Execute the function
match getSystemInfo() with
| Ok info -> ()  // Already printed in function
| Error msg -> eprintfn "%s" msg