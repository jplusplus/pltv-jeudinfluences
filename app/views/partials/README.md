## Note about partials

Template files into this directory will be copied to ```/public``` by `grunt`. 

```.twig``` files will be ignored during this copy because they aims to be included 
by others Twig templates. By doing this we ensure that some file stay "secret" until 
the very last release.