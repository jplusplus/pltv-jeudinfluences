## Chapitre

```js

{
    "title" : "Ce n'\u00e9tait qu'un jeu...", 
    "bilan" : true // tell if the bilan should be shown at the end of the chapter.
}

```

## Scène

| paramètres     |  notes                                                                                      |
|:-------------- | -------------------------------------------------------------------------------------------:|
| next_scene     | optional, no compatible if a scene without choice, in the sequence. Typically for flashback |
| decor          | TODO                                                                                        |
| sequence       | TODO                                                                                        |




### Séquences

| types        |  bouton suivant | paramètres                                      |
|:------------ | ---------------:|:----------------------------------------------- |
| dialogue     |               ✓ | header, body, character                         |
| narrative    |               ✓ | body(str)                                       |
| voixoff      |               ✕ | body(url)                                       |
| video        |               ✓ | body(url)                                       |
| notification |               ✓ | body(str), header, sound                        |
| choice       |               ✕ | body(str), delay, default_option, options(list) |

#### Choices

| paramètres     |  notes                                                                          |
|:-------------- | -------------------------------------------------------------------------------:|
| default_option | default choice after a given delay, can be null for disable automatic selection |
| delay          | required if a default_option is specified                                       |
| options        | list of options                                                                 |

##### Options

```js
{
    "header": "Envoyer un DM \u00e0 Nadia",
    "next_scene": "2.1", // need to be a string to prevent rounding, special cast..
    "outro": "Nadia a bien re\u00e7u votre DM...", // optional, this is a message that has to be shown before the next scene
    "result": [
        {
            "karma": 5,
            "stress": 2,
            "ubm": 10
        }
    ]
}

```

## Annimation lorsqu'un chapitre commence
```
--------------------------------------------------------------------------------------->
| écran noir en fadein
|......| affiche le titre pendant 3s puis disparait en fadeout
            |....| affiche le background de la scène courrante en fadein avec un timeout de 2s
                 | lance la séquence
```

bilan
important de mettre les id en str