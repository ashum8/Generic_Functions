# Generic_Functions
/*
 Generic functions :- Generic code enables you to write flexible, reusable functions and types that can work with any type, subject to requirements that you define. You can write code that avoids duplication and expresses its intent in a clear, abstracted manner.
 */

let IntArr:[Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21]
let StrArr:[String] = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]

// Write a function for finding index in integer type Array.

func findIndexInt(arr:[Int],key:Int) ->Int
{
    for (index,element) in arr.enumerated() {
        if element == key {
            return index
        }
    }
    return -1;
}

// Write a function for finding index in String type Array.

func findIndexStr(arr:[String],key:String) ->Int
{
    for (index,element) in arr.enumerated() {
        if element == key {
            return index
        }
    }
    return -1;
}

findIndexInt(arr: IntArr, key: 20)
findIndexStr(arr: StrArr, key: "k")

// create a generic function for finding the index in the array. due to this function you dont need to write any other function.this support any type of array.

func getIndexOfItems<T:Comparable>(itemsArr :[T],key:T)-> Int
{
    for (index,items) in itemsArr.enumerated() {
        if items == key {
            return index
        }
    }
    return -1;
}

getIndexOfItems(itemsArr: StrArr, key: "k")
getIndexOfItems(itemsArr: IntArr, key: 20)
