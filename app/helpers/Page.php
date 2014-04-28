<?php

namespace app\helpers;

class Page {

    public static function getPage($slug) {
        $page_filename = "pages/{$slug}.md";
        return @file_get_contents($page_filename);
    }
}