## Chapitre

```js

{
    "title" : "Ce n'\u00e9tait qu'un jeu...", 
    "bilan" : true // tell if the bilan should be shown at the end of the chapter.
}

```

## Scène

| paramètres     |  notes                                                                                      |
|:-------------- |:------------------------------------------------------------------------------------------- |
| next_scene     | optional, but required for scene without choice in the sequence (Typically for flashback )  |
| decor          | background, background_transition, soundtrack                                               |
| sequence       | list of events                                                                              |


### Séquences

Un évenement peut être bloquant ou pas. Il est bloquant s'il nécessite une intéraction de l'utilisateur pour enchainer sur l'évenement suivant de la séquence.

| types          |  bouton suivant à la fin | bloquant | paramètres                                      |
|:------------   | ------------------------:| --------:|:----------------------------------------------- |
| dialogue       |                        ✓ |        ✓ | header, body, character                         |
| narrative      |                        ✓ |        ✓ | body(str)                                       |
| voixoff        |                        ✕ |        ✕ | body(url)                                       |
| video          |                        ✓ |        ✓ | body(url)                                       |
| notification   |                        ✓ |        ✓ | body(str), header, sound                        |
| new_background |                        ✕ |        ✕ | body(url), transition                           |
| choice         |                        ✕ |        ✓ | body(str), delay, default_option, options(list) |

Si `choice` n'est pas spécifié, le paramètre `next_scene` doit être reseigné dans l'objet `scene`.

#### Choices

| paramètres     |  notes                                                                          |
|:-------------- |:------------------------------------------------------------------------------- |
| default_option | default choice after a given delay, can be null for disable automatic selection |
| delay          | required if a default_option is specified (in second                            |
| options        | list of options                                                                 |

##### Options

| paramètres     |  notes                                                                          |
|:-------------- |:------------------------------------------------------------------------------- |
| next_scene     | ID of the next scene to display if the user make this choice                    |
| result         | Effects on the static variables (trust,karma,stress,ubm)                        |
| outro          | Opt: Text to display as a feedback after the choice and before the next scene   |


```js
{
    "header": "Envoyer un DM \u00e0 Nadia",
    "next_scene": "2.1", // need to be a string to prevent rounding, special cast..
    "outro": "Nadia a bien re\u00e7u votre DM...", // optional, this is a message that has to be shown before the next scene
    "result": [
        {
            "karma": 5,
            "stress": 2,
            "trust": 2,
            "ubm": 10
        }
    ]
}

```
