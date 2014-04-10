angular.module('spin.constant').constant 'constant.indicators',
    meta:
        rules:
            lessThanOrEqual: 'lte'
            lessThan: 'lt'
            greaterThanOrEqual: 'gte'
            greaterThan: 'gt'
    all: 
        karma:
            start: 0
            max:  50
            min: -50
            gameOver:
                on:   'min'
                rule: 'lte'
        ubm:
            start: 0
            min: 0
            max: 100
            gameOver:
                on:   'max'
                rule: 'gte'

        trust:
            min: 0
            max: 100
            start: 100
            gameOver:
                on:   'min'
                rule: 'lte'
        stress:
            min: 0
            max: 100
            start: 0
            gameOver:
                on:   'max'
                rule: 'gte'
