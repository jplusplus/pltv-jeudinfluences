angular.module('spin.constant').constant 'constant.settings',
    # URL where to find the media
    # (Append using "media" filter )
    mediaUrl          : window.MEDIA_URL or ""
    # Duration of chapter starting (in milliseconds)
    chapterStarting   : 6*1000
    # Some types of sequence have differents behavior
    sequence_with_next: ["dialogue", "narrative", "video", "notification", "voixoff"]
    sequence_blocking : ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
    sequence_dialog   : ["dialogue", "narrative"]
    sequence_skip     : ["new_background"]
    # Refreshing rate for timeouts
    timeoutRefRate : 100
    user_indicators:
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
