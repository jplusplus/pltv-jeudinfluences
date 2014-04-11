API
===


## Career

### GET
	
	/api/career?(token=|email=)

response:

```
{
    "choices": {
        "2.11": 1,
        "2.12": 0
    },
    "context": {
        "UBM": 0,
        "culpabilite": 0,
        "honnetete": 100,
        "karma": 0,
        "stress": 0,
        "trust": 100,
        "tweet": true,
        "ubm": 0
    },
    "reached_scene": "2.14",
    "scenes": [
        "2.12",
        "2.14"
    ],
    "token": "53458de7bedc8952803462"
}
```

Retrieve the career progression for the given token or email from the database

### POST

	/api/career(?token=)

Save the career progression in database.  
expected body : 
```
     {"reached_scene" : "2.2"}
or   {"scene" : "2.1", "choice": 2}  // `choice` is the index of the selected option
```

If token isn't given, it creates one and returns it. You should save it in order to update later the career.

### POST

	/api/career/associate_email?token=

Associate an email to a token.  
expected body : `{"email" : "example@wanadoo.fr"}`

## Story Plot

### GET

	/api/plot

Retrieve the list of opened chapters and their scenes from the `chapters` folder.
See [app/chapters/README.md](../app/chapters/README.md)

## Summary

### GET

    /api/summary?chapter=(&token=)

Retrieve the summary for a chapter.  
If a token is specified, it also returns what choice the user has made.

response:

```json
{
    "1.1": {
        "share_sentence": "Jusqu'ici j'ai fait les bons choix, je gère la crise. Et vous, quels seraient les vôtres ?",
        "title": "Appeler Nadia ?",
        "options": [
            {
                "title": "Vous avez choisi de rappeler Nadia",
                "percentage": 50
            },
            {
                "title": "Vous avez choisi de ne pas rappeler Nadia",
                "percentage": 50
            }
        ],
        "you" : 1
    },
    "1.4": { ... }
}
```