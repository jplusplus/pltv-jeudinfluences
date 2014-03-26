API
===


## Career


### GET
	
	/api/career?(token=|email=)

Retrieve the career progression for the given token or email from the database

### POST

	/api/career(?token=)

Save the career progression in database.  
expected body : career's history in json as a list (see [doc/career.md](career.md)).  
If token isn't given, it creates one and returns it. You should use it after to save again the career.

### PUT

	/api/career(?token=)

Update a career by adding the given history element to the already saved history list.
expected body : career's history element in json as a dictionary (see [doc/career.md](career.md)).  

	/api/career/associate_email?token=

Associate an email to a token.  
expected body : `{"email" : "example@wanadoo.fr"}`

## Story Plot

### GET

	/api/plot

Retrieve the list of opened chapters and their scenes from the `chapters` folder.
See [app/chapters/README.md](../app/chapters/README.md)
