<?php

namespace app\helpers;

class AuthHash {
	public static function create(){
		$secret_hash = "qF23EfM2VwnFoUEx0MbSdzR3OHhzf0";
		$day = date("l");
		$date = date("dmY");
		$hash = sha1($secret_hash.$day.$date);
		return $hash;
	}
	public static function auth($hash){
		if($hash == self::create()){
			return true;
		} else {
			return false;
		}
	}
}