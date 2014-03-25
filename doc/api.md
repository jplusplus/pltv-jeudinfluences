API
===


## Career


### GET
	
	/api/career/:token

Retrieve the career progression for the given token from the database

### POST

	/api/career(/:token)

Save the career progression in database.  
expected body : career's history in json as a list (see [doc/career.md](career.md)).  
If token isn't given, it creates one and returns it. You should use it after to save again the career.


	/api/career/associate_email/:token

Associate an email to a token.  
expected body : `{"email" : "example@wanadoo.fr"}`

## Story Plot

### GET

	/api/plot

Retrieve the list of opened chapters and their scenes from the `chapters` folder.
See [app/chapters/README.md](../app/chapters/README.md)
