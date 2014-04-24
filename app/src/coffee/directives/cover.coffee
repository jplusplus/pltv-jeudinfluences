angular.module('spin.directive').directive "cover", ->    
    restrict: "A"
    replace: false
    link: (scope, element, attrs)->        
        # minimum video width allowed
        min_w = vid_w_orig = parseInt(attrs.minWidth)
        vid_h_orig = parseInt(attrs.minHeight)
        resize = ->
            # use largest scale factor of horizontal/vertical
            scale_h = jQuery(window).width() / vid_w_orig
            scale_v = jQuery(window).height() / vid_h_orig
            scale = (if scale_h > scale_v then scale_h else scale_v)
            # don't allow scaled width < minimum video width
            scale = min_w / vid_w_orig  if scale * vid_w_orig < min_w            
            # now scale the video
            jQuery(element).width scale * vid_w_orig
            jQuery(element).height scale * vid_h_orig

        jQuery(window).on "resize", resize 
        do resize