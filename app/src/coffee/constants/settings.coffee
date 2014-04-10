angular.module('spin.constant').constant 'constant.settings',
    # URL where to find the media
    # (Append using "media" filter )
    mediaUrl        : window.MEDIA_URL or ""
    # Duration of chapter starting (in milliseconds)
    chapterStarting : 4*1000
    # Duration of a feedback appearance
    feedbackDuration: 4*1000
    # Some types of sequence have differents behavior
    sequenceWithNext: ["dialogue", "narrative", "video", "notification", "voixoff"]
    sequenceDialog  : ["dialogue", "narrative"]
    sequenceSkip    : ["new_background"]
    # Some scenes affect the progression
    mainScenes      : 
        "1": ["1.1", "1.4", "1.6"]
        "2": ["2.6", "2.16", "2.27"]
        "3": ["3.10", "3.18", "3.26", "3.28"]
        "4": ["4.17", "4.23", "4.31"]
        "5": ["5.13", "5.26", "5.42"]
        "6": ["6.3", "6.9", "6.13", "6.17", "6.28", "6.33"]
    # Refreshing rate for timeouts
    timeoutRefRate  : 100
    user_indicators :
        karma:
            start: 0
            isgameover: (val)-> val <= -50
        ubm:
            start: 0
            isgameover: (val)-> val >= 100 
        trust:
            start: 100
            isgameover: (val)-> val <= 0  
        stress:
            start: 0
            isgameover: (val)-> val >= 100
