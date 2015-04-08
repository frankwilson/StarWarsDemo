//
//  ArrayUtils.swift
//  StarWarsDemo
//
//  Created by Pavel Kazantsev on 09/04/15.
//  Copyright (c) 2015 Pavel Kazantsev. All rights reserved.
//

import UIKit

func swd_intersect<T where T: Equatable>(first: [T], other: [T]) -> [T] {
    return first.filter({ swd_contains(other, $0) })
}

func swd_contains<T where T: Equatable>(container: [T], element: T) -> Bool {
    for elemToCheck in container {
        if element == elemToCheck {
            return true;
        }
    }
    return false
}

func swd_substract<T where T: Equatable>(first: [T], other: [T]) -> [T] {
    return first.filter({ !swd_contains(other, $0) })
}
