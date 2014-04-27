<?php

namespace app\helpers;

class Game {
	
	public static function getPlot($opening_dates=NULL) {
		/**
		* Return the story (chapter + scene).
		* If an opening_dates array is given, takes care about the returned chapters.
		*/
		$response = array();
		$chapters = glob('chapters/[0-9*].json', GLOB_BRACE);
		foreach ($chapters as $chapter_filename) {
			$chapter_number = basename($chapter_filename, ".json");
			$content        = file_get_contents($chapter_filename);
			$chapter        = json_decode($content, true);
			$opening_date   = isset($opening_dates[$chapter_number]) ? $opening_dates[$chapter_number] : null;
			// if there is an opening date, compare it with today : keep only opened chapters
			if(empty($opening_date) || strtotime(date('Y-m-d H:i:s')) >= strtotime($opening_date))  {
				// retrieve scenes files for the current chapter
				$scenes  = glob('chapters/'.$chapter_number.'.?*.json', GLOB_BRACE);
				$chapter['id']           = $chapter_number; # add the id from filename
				$chapter['opening_date'] = $opening_date; # add the opening_date from config into the chapter object
				$chapter['scenes']       = array();
				foreach ($scenes as $scene_filename) {
					$content     = file_get_contents($scene_filename);
					$scene       = json_decode($content, true);
					$scene["id"] = implode(array_slice(explode(".", basename($scene_filename, ".json")), 1)); # add the id from filename
					$chapter['scenes'][] = $scene;
				}
				$response[] = $chapter;
			}
		}
		return $response;
	}

	public static function computeContext($career){
		/**
		* Compute the context from the given career based on the initial context.
		*/
		$context = array( // initial context
			"trust"       => 0.1,
			"stress"      => 0,
			"karma"       => 0,
			"UBM"         => 0,
			"honnetete"   => 100,
			"culpabilite" => 0
		);

		$plot           = Game::getPlot();
		$reached_scenes = json_decode($career["scenes"], true);
		$reached_scenes = array_splice($reached_scenes, 0, -1); //  remove last scene because we will do it again
		$choices        = json_decode($career["choices"], true);
		foreach ($reached_scenes as $scene_id) {
			$scene = Game::getScene($scene_id);
			// loop over the sequence to compute context from events
			if (isset($scene["sequence"])) {
				foreach ($scene["sequence"] as $event) {
					// check if there are conditions and if they are satisfied
					if (isset($event["result"]) && isset($event["condition"])) {
						$satisfied = true;
						foreach ($event["condition"] as $key => $value) { // over all the conditions
							// check from the context and break if conditions are not satisfied
							if (isset($context[$key])) {
								if ($context[$key] != $value) {
									$satisfied = false;
									break;
								}
							} else {
								if ($value) {
									$satisfied = false;
									break;
								}
							}
						}
						if (!$satisfied) break; // exit the event if conditions are not satisfied
					}
					if (isset($event["result"])) {
						Game::updateContext($context, $event["result"]);
					}
				}
			}
			// search if a choice was made for this scene and compute the new context
			if (isset($choices[$scene_id])) {
				$options = Game::getOptionsFromScene($scene);
				Game::updateContext($context, $options[$choices[$scene_id]]["result"][0]);
			}
		}
		return $context;
	}

	public static function getSummary() {
		/**
		* Return the summary for all chapters
		*/
		$summary = array();
		$summaries = glob('summaries/[0-9*].json', GLOB_BRACE);
		foreach ($summaries as $summary_filename) {
			$chapter = basename($summary_filename, '.json');
			$summary_content = json_decode(file_get_contents($summary_filename), true);
			$summary[$chapter] = $summary_content[$chapter];
		}
		return $summary;
	}

	private static function updateContext(&$context, $update_to){
		/**
		* Update the $context with the given array $update_to.
		* $update_to looks to array("karma" => -5, "trust" => +10)
		* Respect the range of the given field. See $rules.
		*/
		$rules = array(
			"karma"       => array(-50, 50),
			"trust"       => array(0, 100),
			"stress"      => array(0, 100),
			"UBM"         => array(0, 100),
			"honnetete"   => array(0, 100),
			"culpabilite" => array(0, 100)
		);

		foreach ($update_to as $key => $value) {
			if (isset($context[$key]) && is_int($value)) {
					if (isset($rules[$key])) {
						if ($value < 0) {
							if (is_null($rules[$key][0])) {
								$context[$key] = $context[$key] + $value;
							} else {
								$context[$key] = max($rules[$key][0], $context[$key] + $value);
							}
						} else {
							if (is_null($rules[$key][1])) {
								$context[$key] = $context[$key] + $value;
							} else {
								$context[$key] = min($rules[$key][1], $context[$key] + $value);
							}
						}
					} else {
						$context[$key] += $value;
					}
			} else {
				$context[$key] = $value;
			}
		}
	}

	public static function getChapter($chapter_id) {
		/**
		* Return the chapter for the given id (ex: "4")
		*/
		$plot = Game::getPlot();
		foreach ($plot as $chapter) {
			if ($chapter["id"] == (string)$chapter_id) return $chapter;
		}
	}

	public static function getScene($full_scene_id) {
		/**
		* Return the scene for the given id (ex: "4.scene_name")
		*/
		$ids        = explode(".", $full_scene_id);
		$chapter_id = $ids[0];
		$scene_id   = $ids[1];
		$chapter    = Game::getChapter($chapter_id);
		foreach ($chapter['scenes'] as $scene) {
			if ($scene["id"] == $scene_id) return $scene;
		}
	}

	public static function getOptionsFromScene($scene) {
		/**
		* Return the list of option given a $scene object
		*/
		foreach ($scene["sequence"] as $event) {
			if ($event["type"] == "choice") {
				return $event["options"];
			}
		}
	}
}


// EOF
