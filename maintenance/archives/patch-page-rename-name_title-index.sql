-- This file is automatically generated using maintenance/generateSchemaChangeSql.php.
-- Source: maintenance/abstractSchemaChanges/patch-page-rename-name_title-index.json
-- Do not modify this file directly.
-- See https://www.mediawiki.org/wiki/Manual:Schema_changes
DROP  INDEX name_title ON  /*_*/page;
CREATE UNIQUE INDEX page_name_title ON  /*_*/page (page_namespace, page_title);