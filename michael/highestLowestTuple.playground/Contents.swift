//: Playground - noun: a place where people can play

import UIKit

//Write a function that takes in an array of numbers, and returns the lowest and highest numbers as a tuple.


let myarray = [3,7,2,1,9,20]
let otherArray = [4,8,12,283674872364,12365]
//
//let first = array.sort().first
//let last = array.sort().last
//
//let tuple: (Int, Int) = (first!, last!)
//print(tuple)

func gimmeTuple(input: [Int]) -> (Int, Int) {
    
    let array = input
    let first = input.sort().first
    let last = input.sort().last
    return (first!, last!)
    
}


gimmeTuple(myarray)
gimmeTuple(otherArray)


