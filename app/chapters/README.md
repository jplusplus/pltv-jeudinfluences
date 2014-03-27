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


`next_scene` peut-être **une chaine** représentant une scène ("2.2" par exemple) **ou une condition** sur la variable `karma` comme ci dessous :

```json
"next_scene" : {
    "positif_karma" : "2.2", // si karma est positif ( >=0 ), aller à la scène 2.2
    "negatif_karma" : "2.1"  // si karma est négatif ( <0 ), aller à la scène 2.1
}
```

### Séquences

Un évenement (appelé aussi "réplique") peut être bloquant ou pas. Il est bloquant s'il nécessite d'être terminé pour enchainer sur l'évenement suivant de la séquence.

Chaque évenement peut avoir **un paramètre "condition"**. Dans ce cas là, la réplique ne s'affiche que si la condition est remplie. Exemple d'utilisation : `"condition": {"interview_acceptee":true, "i_want_to_die": true}`. Ici `interview_acceptee` __ET__ `i_want_to_die` doivent être vrais pour afficher la réplique.

Un évenement `new_background` peut avoir **un paramètre "timeout"**. Cela indique le temps (en secondes) après lequel l'événement doit s'afficher. Ce timeout est **non-bloquant**, c'est à dire que les autres événements continuent de défiler. L'évenement est ainsi reporté à plus tard.

Chaque évenement peut avoir **un paramètre "result"**. Ce dictionnaire permet d'incrémenter ou décrémenter les variables de contextes.


| types          |  bouton suivant à la fin | bloquant | paramètres                                                                  |
|:------------   | ------------------------:| --------:|:----------------------------------------------------------------------------|
| dialogue       |                        ✓ |        ✓ | header, body, character, result, condition                                  |
| narrative      |                        ✓ |        ✓ | body(str), result, condition                                                |
| voixoff        |                        ✕ |        ✓ | body(url), result, condition                                                |
| video          |                        ✓ |        ✓ | body(url), result, condition                                                |
| notification   |                        ✓ |        ✓ | body(str), header, sound, result, condition                                 |
| new_background |                        ✕ |        ✕ | body(url), transition, result, condition, timeout                           |
| choice         |                        ✕ |        ✓ | body(str), delay, default_option, options(list), condition                  |

Si `choice` n'est pas spécifié, le paramètre `next_scene` doit être reseigné dans l'objet `scene`.

#### Choices

| paramètres     |  notes                                                                          |
|:-------------- |:------------------------------------------------------------------------------- |
| default_option | default choice after a given delay, can be null for disable automatic selection |
| delay          | required if a default_option is specified (in seconds)                          |
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
    "result": {
        "karma": 5,
        "stress": 2,
        "trust": 2,
        "ubm": 10
    }
}

```
