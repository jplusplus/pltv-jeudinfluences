Career
======

A career is a list of scene done which include to the option selected if exists.  
Scene doesn't have necessary a choice (flashback for exemple).  
Or the choice can be implicit, with the `default_choice` scene's parameter.

```json
{
	"token" : "3d09baddc21a365b7da5ae4d0aa5cb95",
	"history" : [
		{
			"scene" : "1.1",
			"choice" : {
				"header": "Envoyer un DM \u00e0 Nadia",
				"next_scene": "2.1",
				"outro": "Nadia a bien re\u00e7u votre DM...",
				"result": {
					"karma": 5,
					"stress": 2,
					"trust": 2,
					"ubm": 10
				}
			}
		},
		{
			"scene" : "2.1",
			"choice" : {
				"header": "Non",
				"next_scene": "2.2",
				"result": {
					"karma": 5,
					"stress": 5,
					"ubm": 10
				}
			}
		}
	]
}
```

__reached scene__   : `career.path[-1]` (last element of `path`)
__current context__ : this is the value of the context variables. To retrieve the context, loop over the history and compute each variable, starting from the initial values (TODO: to be defined somewhere).
