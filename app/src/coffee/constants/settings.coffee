angular.module('spin.constant').constant 'constant.settings',
    # URL where to find the media
    # (Append using "media" filter )
    mediaUrl          : window.MEDIA_URL or ""
    # Duration of chapter starting (in milliseconds)
    chapterStarting   : 6*1000
    # Some types of sequence have differents behavior
    sequenceWithNext: ["dialogue", "narrative", "video", "notification", "voixoff"]
    sequenceBlocking : ["dialogue", "narrative", "voixoff", "video", "notification", "choice"]
    sequenceDialog   : ["dialogue", "narrative"]
    sequenceSkip     : ["new_background"]
    # Refreshing rate for timeouts
    timeoutRefRate  : 100
