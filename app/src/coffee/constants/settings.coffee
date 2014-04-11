angular.module('spin.constant').constant 'constant.settings',
    # URL where to find the media
    # (Append using "media" filter )
    mediaUrl          : window.MEDIA_URL or ""
    # Animations
    chapterEntrance   : 6*1000
    sceneEntrance     : 1*1000
    # Some types of sequence have differents behavior
    sequenceWithNext  : ["dialogue", "narrative", "video", "notification", "voixoff"]
    sequenceBlocking  : ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
    sequenceDialog    : ["dialogue", "narrative"]
    sequenceSkip      : ["new_background"]
    # Refreshing rate for timeouts
    timeoutRefRate    : 100
    # Some scenes affect the progression
    mainScenes        :
        "1": ["1.1", "1.4", "1.6"]
        "2": ["2.6", "2.16", "2.27"]
        "3": ["3.10", "3.18", "3.26", "3.28"]
        "4": ["4.17", "4.23", "4.31"]
        "5": ["5.13", "5.26", "5.42"]
        "6": ["6.3", "6.9", "6.13", "6.17", "6.28", "6.33"]