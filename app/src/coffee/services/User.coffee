angular.module("spin.service").factory "User", ['$resource', ($resource)-> 
    # ──────────────────────────────────────────────────────────────────────────
    # Private attributes
    # ──────────────────────────────────────────────────────────────────────────
    chapter = 0    
    # ──────────────────────────────────────────────────────────────────────────
    # Public method
    # ──────────────────────────────────────────────────────────────────────────
    chapter: (c)->
        if c? 
            chapter = c
        chapter
]
# EOF