//: Playground - noun: a place where people can play

import UIKit



//Given an array of ints of odd length, return a new array length 3 containing the elements from the middle of the array. The array length will be at least 3.

let oddArray = [11,12,15,14,13,16,17,18,19]
let otherArray = [3,4,5,6,7,8,9,10,11]
//should return [3,4,5]

func getMiddleThreeValues(input: [Int]) -> [Int] {
    var newArray = [Int]()

    let middle = input.count/2-1
    let range = middle + 2

    for value in middle...range{
        newArray.append(input[value])
    }
    
    return newArray
}

getMiddleThreeValues(oddArray)
getMiddleThreeValues(otherArray)

