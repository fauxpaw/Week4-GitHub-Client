//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"


func checkForRemainder(input: Int) -> Bool {
    
    if input % 10 == 2 {
        return true
    }
    else if input % 10 == 8 {
        return true
    }
    else { return false}
    
}

checkForRemainder(100)
checkForRemainder(18)
checkForRemainder(22)
