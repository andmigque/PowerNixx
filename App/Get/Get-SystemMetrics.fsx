open System
open System.Diagnostics

// Define different types of system metrics
type SystemMetric =
    | CpuUsage of float
    | MemoryUsage of float
    | DiskSpace of string * float  // (path, percentage free)
    | ProcessCount of int
    | Temperature of float option  // Some systems might not report temp

// Define threshold levels
type AlertLevel =
    | Normal
    | Warning
    | Critical

// Function to analyze metrics
let analyzeMetric = function
    | CpuUsage usage when usage > 90.0 -> Critical
    | CpuUsage usage when usage > 70.0 -> Warning
    | CpuUsage _ -> Normal
    | MemoryUsage mem when mem > 90.0 -> Critical
    | MemoryUsage mem when mem > 80.0 -> Warning
    | MemoryUsage _ -> Normal
    | DiskSpace (path, free) when free < 10.0 -> Critical
    | DiskSpace (path, free) when free < 20.0 -> Warning
    | DiskSpace _ -> Normal
    | ProcessCount count when count > 500 -> Warning
    | ProcessCount _ -> Normal
    | Temperature None -> Normal  // Can't analyze if no temperature data
    | Temperature (Some temp) when temp > 80.0 -> Critical
    | Temperature (Some temp) when temp > 70.0 -> Warning
    | Temperature _ -> Normal

// Function to get current metrics
let getCurrentMetrics() =
    let proc = Process.GetProcesses()
    [
        CpuUsage(float (GC.GetTotalMemory(false)) / 100000.0)  // Simulated CPU usage
        MemoryUsage(float (GC.GetTotalMemory(true)) / 1000000.0)
        DiskSpace("/", 25.0)  // Simulated disk space
        ProcessCount(proc.Length)
        Temperature(Some 75.0)  // Simulated temperature
    ]

// Monitor and report
let monitorSystem() =
    getCurrentMetrics()
    |> List.map (fun metric -> metric, analyzeMetric metric)
    |> List.iter (function
        | (CpuUsage v, level) -> 
            printfn "CPU Usage: %.1f%% (%A)" v level
        | (MemoryUsage v, level) -> 
            printfn "Memory Usage: %.1f MB (%A)" v level
        | (DiskSpace (path, free), level) -> 
            printfn "Disk Space %s: %.1f%% free (%A)" path free level
        | (ProcessCount v, level) -> 
            printfn "Process Count: %d (%A)" v level
        | (Temperature None, _) -> 
            printfn "Temperature: Not available"
        | (Temperature (Some t), level) -> 
            printfn "Temperature: %.1f°C (%A)" t level
    )

// Run the monitor
printfn "\nSystem Monitor Report"
printfn "--------------------"
monitorSystem()