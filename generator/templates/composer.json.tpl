{
  "name": "{{VENDOR_SLUG}}/{{PLUGIN_SLUG}}",
  "description": "{{PLUGIN_DESCRIPTION}}",
  "type": "wordpress-plugin",
  "require-dev": {
    "dealerdirect/phpcodesniffer-composer-installer": "^1.1",
    "squizlabs/php_codesniffer": "^3.10",
    "phpcsstandards/phpcsextra": "^1.2",
    "phpcsstandards/phpcsutils": "^1.1",
    "wp-coding-standards/wpcs": "^3.1"
  },
  "scripts": {
    "lint": "phpcs .",
    "lint-fix": "phpcbf .",
    "i18n:pot": "wp i18n make-pot . languages/{{PLUGIN_TEXT_DOMAIN}}.pot --domain={{PLUGIN_TEXT_DOMAIN}} --exclude=node_modules,vendor,.git,tests"
  },
  "config": {
    "allow-plugins": {
      "dealerdirect/phpcodesniffer-composer-installer": true
    }
  }
}
