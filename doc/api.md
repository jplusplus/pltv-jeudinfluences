API
===


## Career

### GET
	
	/api/career?(token=|email=)

Retrieve the career progression for the given token or email from the database

### POST

	/api/career(?token=)

Save the career progression in database.  
expected body : 
```
{
	"reached_scene" : "2.2",
	"context":{
		"karma":5,
		"stress":2,
		"trust":2,
		"ubm":10
	}
}
```

(both of `reached_scene` and `context` are optional).  
If token isn't given, it creates one and returns it. You should save it in order to update later the career.

### PUT

	/api/career/associate_email?token=

Associate an email to a token.  
expected body : `{"email" : "example@wanadoo.fr"}`

## Story Plot

### GET

	/api/plot

Retrieve the list of opened chapters and their scenes from the `chapters` folder.
See [app/chapters/README.md](../app/chapters/README.md)
