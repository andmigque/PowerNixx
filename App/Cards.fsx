// let <function name> <parameters> = <function body>
// let convert (a:string) :int =
//    int a
// let no = 10
// let isDivisibleByTwo = no % 2 = 0
// printfn "Divisible by two %b" isDivisibleByTwo

// let cardFace card = 
//    let no = card % 13
//    if no = 1 then "Ace"
//    elif no = 0 then "King"
//    elif no = 12 then "Queen"
//    elif no = 11 then "Jack"
//    else string no
open System
open System.Text

let kingHearts = fun () -> 
    let sb = new StringBuilder()
    sb.Append( "\n") |> ignore
    sb.Append( "♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️ 🎲 ♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️\n")|> ignore
    sb.Append( "♥️♥️                      ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️     /\   /\   /\     ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️    /  \_/  \_/  \    ♥️♥️\n") |> ignore
    sb.Append( "🎲   ( 👑   👑   👑 )   🎲\n") |> ignore
    sb.Append( "♥️♥️   †..............†   ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️    \     💔     /    ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️     ------------     ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️                      ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️ 🎲 ♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️") |> ignore
    sb.Append( "\n") |> ignore
    sb.ToString()

let queenHearts = fun () -> 
    let sb = new StringBuilder()
    sb.Append( "\n") |> ignore
    sb.Append( "♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️ 🎲 ♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️\n")|> ignore
    sb.Append( "♥️♥️                      ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️     /\        /\     ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️    /🔺\\__🔺__/🔺\    ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️    \ 🔴__🔴__🔴 /    ♥️♥️\n") |> ignore
    sb.Append( "🎲   (⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆⋆)   🎲\n") |> ignore
    sb.Append( "♥️♥️    \  💗 💗 💗  /    ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️     ------------     ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️                      ♥️♥️\n") |> ignore
    sb.Append( "♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️ 🎲 ♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️♥️") |> ignore
    sb.Append( "\n") |> ignore
    sb.ToString()
// ⋆༺𓆩☠︎︎𓆪༻⋆
// ( ͡° ʖ ͡°)
//  ╰ ┈

let rnd = new Random()
let cardNumber = rnd.Next(12,12)

let cardFace card = 
    let no = card % 13
    if no = 1 then "Ace"
    elif no = 0 then kingHearts()
    elif no = 12 then queenHearts()
    elif no = 11 then "Jack"
    else string no

printfn "%s" (cardFace cardNumber)