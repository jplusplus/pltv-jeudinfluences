<?php

namespace app;

require '../composer_modules/autoload.php';

class SpinTwigExtension extends \Slim\Views\TwigExtension {

	public function getName() {
		return 'spin-twig-extension';
	}

	public function getFilters() {
		return array(
			new \Twig_SimpleFilter('md5', 'md5_file'),
		);
	}

}