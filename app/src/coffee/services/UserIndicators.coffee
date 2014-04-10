assert = (cond)-> if !cond then throw "Assertion failed"

angular.module("spin.service").factory "UserIndicators", [
    'constant.indicators',
    (INDICATORS)->
        new class UserIndicators
            # ──────────────────────────────────────────────────────────────────────────
            # Public method
            # ──────────────────────────────────────────────────────────────────────────
            constructor: ->
                @bindRules      INDICATORS.meta.rules
                @bindIndicators INDICATORS.all

            bindRules: (rules) =>
                @genericFunctions = @genericFunctions or {}

                @genericFunctions[ rules.lessThanOrEqual    ] = (a, b)-> a <= b
                @genericFunctions[ rules.lessThan           ] = (a, b)-> a < b
                @genericFunctions[ rules.greaterThanOrEqual ] = (a, b)-> a >= b
                @genericFunctions[ rules.greaterThan        ] = (a, b)-> a > b

            bindIndicators: (indicators) =>
                for indicator_key, indicator of indicators
                    game_over_rule   = indicator.gameOver.rule
                    game_over_value  = indicator[indicator.gameOver.on]
                    generic_function = @genericFunctions[game_over_rule]

                    @[indicator_key] =
                        _meta: indicator
                        gameOverFunction: generic_function
                        gameOverValue: game_over_value
                        isGameOver: (val)-> this.gameOverFunction(val, this.gameOverValue)

]
# EOF