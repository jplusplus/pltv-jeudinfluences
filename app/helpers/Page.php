<?php

namespace app\helpers;

class Page {

    public static function getPage($slug) {
        $page_filename = basename("pages", $slug, ".md");
        echo $page_filename;
        return file_get_contents($page_filename);
    }
}