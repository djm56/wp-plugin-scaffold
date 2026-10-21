<?php

/**
 * WP Plugin Scaffold Generator.
 *
 * Config-driven generator for WordPress plugin scaffolds. Every brand-bearing
 * value (vendor, URLs, CSS prefix, admin menu label) comes from the config's
 * "brand" block. Nothing about the generator's own authors is baked into the
 * plugins it produces.
 *
 * PHP version 7.4+
 *
 * @category Tooling
 * @package  WP_Plugin_Scaffold
 * @license  GPL-2.0-or-later https://www.gnu.org/licenses/gpl-2.0.html
 * @link     https://github.com/  Replace with this repository's URL.
 */

if (php_sapi_name() !== 'cli') {
    fwrite(STDERR, "This script must run in CLI mode.\n");
    exit(1);
}

PluginScaffoldGenerator::run($argv);

/**
 * CLI generator entry class.
 *
 * @category Tooling
 * @package  WP_Plugin_Scaffold
 * @license  GPL-2.0-or-later https://www.gnu.org/licenses/gpl-2.0.html
 * @link     https://github.com/  Replace with this repository's URL.
 */
class PluginScaffoldGenerator
{
    /**
     * Execute generator flow.
     *
     * @param array<int, string> $argv CLI args.
     *
     * @return void
     */
    public static function run(array $argv): void
    {
        $args = self::_parseArgs($argv);
        self::_validateRequiredArgs($args);

        $config = self::_loadConfig($args['config']);
        $type = $args['type'];

        if (!in_array($type, array('free', 'pro'), true)) {
            self::_fail("Invalid --type. Use 'free' or 'pro'.");
        }

        // Order matters: resolve the requested variant before validating the
        // WP.org fields, so asking for --type free on a pro-only config says
        // "no free section" rather than complaining about a missing WP.org
        // field for a variant that was never meant to exist.
        self::_validateBrand($config);
        $variant = self::_getVariant($config, $type);
        self::_validateVariant($variant, $type);
        self::_validateConfig($config, $type);

        $features = array_merge(
            array(
                'analytics' => false,
                'admin_analytics' => false,
                'cron' => false,
                'meta_registration' => false,
                'bulk_actions' => false,
                'shortcode' => false,
                'ajax' => false,
                'has_css' => true,
                'has_js' => false,
                // Admin-only by default. Set true only for plugins that
                // genuinely render or filter on the front end; it emits the
                // wp_enqueue_scripts hook and the the_content filter.
                'frontend' => false,
            ),
            isset($variant['features']) && is_array($variant['features'])
                ? $variant['features']
                : array()
        );

        self::_validateFeatures($features);

        $templateDir = __DIR__ . '/templates';
        $outputRoot = rtrim($args['output'], '/');
        $pluginDir = $outputRoot . '/' . $variant['slug'];

        self::_mkdirIfMissing($pluginDir);
        self::_mkdirIfMissing($pluginDir . '/includes');
        self::_mkdirIfMissing($pluginDir . '/languages');

        if (!empty($features['has_css'])) {
            self::_mkdirIfMissing($pluginDir . '/assets/css');
        }

        if (!empty($features['has_js'])) {
            self::_mkdirIfMissing($pluginDir . '/assets/js');
        }

        $context = self::_buildContext($config, $variant, $type, $features);
        $conditions = self::_buildConditions($config, $type, $features);

        self::_writeFromTemplate(
            $templateDir . '/plugin-entry.php.tpl',
            $pluginDir . '/' . $variant['plugin_file'],
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/class-main.php.tpl',
            $pluginDir . '/includes/class-' . $variant['slug'] . '.php',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/class-module.php.tpl',
            $pluginDir . '/includes/class-' . $variant['slug'] . '-module.php',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/class-settings.php.tpl',
            $pluginDir . '/includes/class-' . $variant['slug'] . '-settings.php',
            $context,
            $conditions
        );

        if (!empty($features['analytics'])) {
            self::_writeFromTemplate(
                $templateDir . '/class-analytics.php.tpl',
                $pluginDir . '/includes/class-' . $variant['slug']
                    . '-analytics.php',
                $context,
                $conditions
            );
        }

        if (!empty($features['admin_analytics'])) {
            self::_writeFromTemplate(
                $templateDir . '/class-admin-analytics.php.tpl',
                $pluginDir . '/includes/class-' . $variant['slug']
                    . '-admin-analytics.php',
                $context,
                $conditions
            );
        }

        self::_writeFromTemplate(
            $templateDir . '/composer.json.tpl',
            $pluginDir . '/composer.json',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/package.json.tpl',
            $pluginDir . '/package.json',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/phpcs.xml.dist.tpl',
            $pluginDir . '/phpcs.xml.dist',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/uninstall.php.tpl',
            $pluginDir . '/uninstall.php',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/README.md.tpl',
            $pluginDir . '/README.md',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/readme.txt.tpl',
            $pluginDir . '/readme.txt',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/CHANGELOG.md.tpl',
            $pluginDir . '/CHANGELOG.md',
            $context,
            $conditions
        );

        self::_writeFromTemplate(
            $templateDir . '/starter.pot.tpl',
            $pluginDir . '/languages/' . $variant['text_domain'] . '.pot',
            $context,
            $conditions
        );

        if (!empty($features['has_css'])) {
            self::_writeFromTemplate(
                $templateDir . '/admin.css.tpl',
                $pluginDir . '/assets/css/admin.css',
                $context,
                $conditions
            );
        }

        if (!empty($features['has_js'])) {
            self::_writeFromTemplate(
                $templateDir . '/admin.js.tpl',
                $pluginDir . '/assets/js/admin.js',
                $context,
                $conditions
            );
        }

        fwrite(STDOUT, "Generated: {$pluginDir}\n");
    }

    /**
     * Parse CLI args.
     *
     * @param array<int, string> $argv CLI args.
     *
     * @return array<string, string>
     */
    private static function _parseArgs(array $argv): array
    {
        $parsed = array();

        for ($i = 1; $i < count($argv); $i++) {
            $part = $argv[$i];
            if (strpos($part, '--') !== 0) {
                continue;
            }

            $key = substr($part, 2);
            $value = isset($argv[$i + 1]) ? $argv[$i + 1] : null;

            if ($value !== null && strpos($value, '--') !== 0) {
                $parsed[$key] = $value;
                $i++;
            }
        }

        return $parsed;
    }

    /**
     * Validate required CLI args.
     *
     * @param array<string, string> $args Parsed args.
     *
     * @return void
     */
    private static function _validateRequiredArgs(array $args): void
    {
        $required = array('config', 'type', 'output');

        foreach ($required as $field) {
            if (empty($args[$field])) {
                self::_fail("Missing required argument: --{$field}");
            }
        }
    }

    /**
     * Load config file.
     *
     * @param string $path Config path.
     *
     * @return array<string, mixed>
     */
    private static function _loadConfig(string $path): array
    {
        if (!file_exists($path)) {
            self::_fail("Config not found: {$path}");
        }

        $content = file_get_contents($path);
        $json = json_decode((string) $content, true);

        if (json_last_error() !== JSON_ERROR_NONE || !is_array($json)) {
            self::_fail('Invalid JSON config: ' . json_last_error_msg());
        }

        return $json;
    }

    /**
     * Resolve free/pro variant from config.
     *
     * @param array<string, mixed> $config Config data.
     * @param string               $type   Variant type.
     *
     * @return array<string, mixed>
     */
    private static function _getVariant(array $config, string $type): array
    {
        if (empty($config[$type]) || !is_array($config[$type])) {
            self::_fail(
                "This config has no '{$type}' section, so there is no "
                . "{$type} variant to generate. Check --type."
            );
        }

        return $config[$type];
    }

    /**
     * Validate variant contract.
     *
     * @param array<string, mixed> $variant Variant config.
     * @param string               $type    Variant type.
     *
     * @return void
     */
    private static function _validateVariant(array $variant, string $type): void
    {
        $requiredFields = array(
            'name',
            'slug',
            'text_domain',
            'description',
            'plugin_uri',
            'version',
            'constant_prefix',
            'option_key',
            'namespace',
            'main_class',
            'module_class',
            'settings_class',
            'plugin_file',
        );

        foreach ($requiredFields as $field) {
            if (empty($variant[$field])) {
                self::_fail("Missing field '{$field}' in {$type} section.");
            }
        }

        if ((string) $variant['slug'] !== (string) $variant['text_domain']) {
            self::_fail(
                "Field mismatch in {$type} section: slug and text_domain must match."
            );
        }
    }

    /**
     * Validate the brand block.
     *
     * Every value that identifies WHO is shipping the plugin lives here, and
     * all of it is mandatory. The generator has no house brand to fall back
     * on by design — see _buildContext().
     *
     * @param array<string, mixed> $config Config data.
     *
     * @return void
     */
    private static function _validateBrand(array $config): void
    {
        if (empty($config['brand']) || !is_array($config['brand'])) {
            self::_fail(
                'Missing "brand" config block. It must define: vendor, '
                . 'vendor_slug, author_uri, css_prefix, menu_parent_label.'
            );
        }

        $brand = $config['brand'];
        $required = array(
            'vendor',
            'vendor_slug',
            'author_uri',
            'css_prefix',
            'menu_parent_label',
        );

        foreach ($required as $field) {
            if (empty($brand[$field]) || !is_string($brand[$field])) {
                self::_fail("Missing brand field: brand.{$field}");
            }
        }

        // Composer vendor names: lowercase alphanumeric with - . _ separators.
        if (!preg_match('/^[a-z0-9]([_.-]?[a-z0-9]+)*$/', $brand['vendor_slug'])) {
            self::_fail(
                'brand.vendor_slug must be a valid Composer vendor name '
                . '(lowercase alphanumeric, separated by - . or _).'
            );
        }

        // CSS prefix becomes a class-name stem, so it must be a usable CSS
        // identifier start and must not already carry a trailing hyphen.
        if (!preg_match('/^[a-z][a-z0-9]*(-[a-z0-9]+)*$/', $brand['css_prefix'])) {
            self::_fail(
                'brand.css_prefix must be lowercase, start with a letter, and '
                . 'use single hyphens between words (e.g. "acme" or "acme-wp"). '
                . 'Do not include a trailing hyphen.'
            );
        }

        if (!preg_match('#^https?://#', $brand['author_uri'])) {
            self::_fail('brand.author_uri must be an http(s) URL.');
        }
    }

    /**
     * Validate global WP.org-oriented config fields.
     *
     * @param array<string, mixed> $config Config data.
     * @param string               $type   Variant type.
     *
     * @return void
     */
    private static function _validateConfig(array $config, string $type): void
    {
        if ($type !== 'free') {
            return;
        }

        $requiredRoot = array(
            'license_uri',
            'contributor_usernames',
            'plugin_tags',
        );

        foreach ($requiredRoot as $field) {
            if (empty($config[$field]) || !is_string($config[$field])) {
                self::_fail(
                    "Missing required config field for free variant: {$field}"
                );
            }
        }

        $tags = array_filter(
            array_map(
                'trim',
                explode(',', (string) $config['plugin_tags'])
            )
        );

        if (count($tags) > 5) {
            self::_fail('plugin_tags must contain 5 tags or fewer for WP.org.');
        }
    }

    /**
     * Validate feature flags.
     *
     * @param array<string, mixed> $features Feature flags.
     *
     * @return void
     */
    private static function _validateFeatures(array $features): void
    {
        foreach ($features as $name => $value) {
            if (!is_bool($value)) {
                self::_fail("Feature '{$name}' must be true/false.");
            }
        }
    }

    /**
     * Build replacement context.
     *
     * @param array<string, mixed> $config   Config data.
     * @param array<string, mixed> $variant  Variant data.
     * @param string               $type     Variant type.
     * @param array<string, bool>  $features Feature flags.
     *
     * @return array<string, string>
     */
    private static function _buildContext(
        array $config,
        array $variant,
        string $type,
        array $features
    ): array {
        $pluginLabel = isset($config['family'])
            ? (string) $config['family']
            : 'plugin';

        // Brand values are validated up front by _validateBrand(), so they are
        // read here without defaults on purpose. A generator that quietly
        // substitutes its own author's name into someone else's plugin is a
        // bug, not a convenience: the failure is silent and ships.
        $brand = $config['brand'];
        $vendor = (string) $brand['vendor'];
        $vendorSlug = (string) $brand['vendor_slug'];
        $authorUri = (string) $brand['author_uri'];
        $cssPrefix = (string) $brand['css_prefix'];
        $menuParentLabel = (string) $brand['menu_parent_label'];

        // Non-brand-bearing technical defaults are safe to supply.
        $requiresWp = isset($config['requires_at_least'])
            ? (string) $config['requires_at_least']
            : '6.0';
        $testedUpTo = isset($config['tested_up_to'])
            ? (string) $config['tested_up_to']
            : '6.8';
        $requiresPhp = isset($config['requires_php'])
            ? (string) $config['requires_php']
            : '7.4';
        $license = isset($config['license'])
            ? (string) $config['license']
            : 'GPL-2.0-or-later';
        $licenseUri = isset($config['license_uri'])
            ? (string) $config['license_uri']
            : 'https://www.gnu.org/licenses/gpl-2.0.html';

        // Required for free (WP.org) by _validateConfig(); genuinely unused
        // for pro, where an empty string is correct rather than a guess.
        $contributors = isset($config['contributor_usernames'])
            ? (string) $config['contributor_usernames']
            : '';
        $pluginTags = isset($config['plugin_tags'])
            ? (string) $config['plugin_tags']
            : '';
        $allowFreeUpsell = isset($config['allow_free_upsell'])
            ? (bool) $config['allow_free_upsell']
            : true;
        $adminMenuPath = $menuParentLabel . ' > ' . (string) $variant['name'];
        $isFreePlugin = $type === 'free';

        return array(
            'FAMILY' => $pluginLabel,
            'TYPE' => $type,
            'PLUGIN_NAME' => (string) $variant['name'],
            'PLUGIN_SLUG' => (string) $variant['slug'],
            'PLUGIN_URI' => (string) $variant['plugin_uri'],
            'PLUGIN_DESCRIPTION' => (string) $variant['description'],
            'PLUGIN_VERSION' => (string) $variant['version'],
            'PLUGIN_TEXT_DOMAIN' => (string) $variant['text_domain'],
            'PLUGIN_OPTION_KEY' => (string) $variant['option_key'],
            'PLUGIN_CONSTANT_PREFIX' => strtoupper(
                (string) $variant['constant_prefix']
            ),
            // Hook/action names must use underscores (WPCS
            // WordPress.NamingConventions.ValidHookName). The slug is
            // hyphenated, so hooks derive from the constant prefix instead.
            'HOOK_PREFIX' => strtolower(
                (string) $variant['constant_prefix']
            ),
            'PLUGIN_NAMESPACE' => (string) $variant['namespace'],
            'PLUGIN_MAIN_CLASS' => (string) $variant['main_class'],
            'PLUGIN_MODULE_CLASS' => (string) $variant['module_class'],
            'PLUGIN_SETTINGS_CLASS' => (string) $variant['settings_class'],
            'PLUGIN_ANALYTICS_CLASS' => (string) $variant['main_class']
                . '_Analytics',
            'PLUGIN_ADMIN_ANALYTICS_CLASS' => (string) $variant['main_class']
                . '_Admin_Analytics',
            'PLUGIN_FILE' => (string) $variant['plugin_file'],
            'PLUGIN_CLASS_FILE' => 'class-' . (string) $variant['slug'] . '.php',
            'PLUGIN_MODULE_FILE' => 'class-' . (string) $variant['slug']
                . '-module.php',
            'PLUGIN_SETTINGS_FILE' => 'class-' . (string) $variant['slug']
                . '-settings.php',
            'PLUGIN_ANALYTICS_FILE' => 'class-' . (string) $variant['slug']
                . '-analytics.php',
            'PLUGIN_ADMIN_ANALYTICS_FILE' => 'class-' . (string) $variant['slug']
                . '-admin-analytics.php',
            'VENDOR' => $vendor,
            'VENDOR_SLUG' => $vendorSlug,
            'CSS_PREFIX' => $cssPrefix,
            'MENU_PARENT_LABEL' => $menuParentLabel,
            'AUTHOR_URI' => $authorUri,
            'REQUIRES_WP' => $requiresWp,
            'TESTED_UP_TO' => $testedUpTo,
            'REQUIRES_PHP' => $requiresPhp,
            'LICENSE' => $license,
            'LICENSE_URI' => $licenseUri,
            'CONTRIBUTOR_USERNAMES' => $contributors,
            'PLUGIN_TAGS' => $pluginTags,
            'ADMIN_MENU_PATH' => $adminMenuPath,
            'IS_FREE_PLUGIN' => self::_boolToPhp($isFreePlugin),
            'ALLOW_FREE_UPSELL' => self::_boolToPhp($allowFreeUpsell),
            'FEATURE_ANALYTICS' => self::_boolToPhp($features['analytics']),
            'FEATURE_ADMIN_ANALYTICS' => self::_boolToPhp(
                $features['admin_analytics']
            ),
            'FEATURE_CRON' => self::_boolToPhp($features['cron']),
            'FEATURE_META_REGISTRATION' => self::_boolToPhp(
                $features['meta_registration']
            ),
            'FEATURE_BULK_ACTIONS' => self::_boolToPhp($features['bulk_actions']),
            'FEATURE_SHORTCODE' => self::_boolToPhp($features['shortcode']),
            'FEATURE_AJAX' => self::_boolToPhp($features['ajax']),
            'FEATURE_HAS_CSS' => self::_boolToPhp($features['has_css']),
            'FEATURE_HAS_JS' => self::_boolToPhp($features['has_js']),
            'FEATURE_FRONTEND' => self::_boolToPhp($features['frontend']),
        );
    }

    /**
     * Build the conditional-block flag map.
     *
     * These drive {{#FLAG}}...{{/FLAG}} and {{^FLAG}}...{{/FLAG}} blocks in
     * the templates. Prefer a conditional block over emitting `if ( false )`
     * into generated code: unreachable scaffolding that ships to customers is
     * how an "Upgrade to Pro" screen ended up inside a premium-only plugin.
     *
     * @param array<string, mixed> $config   Config data.
     * @param string               $type     Variant type.
     * @param array<string, bool>  $features Feature flags.
     *
     * @return array<string, bool>
     */
    private static function _buildConditions(
        array $config,
        string $type,
        array $features
    ): array {
        $allowFreeUpsell = isset($config['allow_free_upsell'])
            ? (bool) $config['allow_free_upsell']
            : true;
        $isFree = $type === 'free';

        return array(
            'IS_FREE' => $isFree,
            'IS_PRO' => !$isFree,
            'SHOW_UPSELL' => $isFree && $allowFreeUpsell,
            'HAS_ANALYTICS' => (bool) $features['analytics'],
            'HAS_ADMIN_ANALYTICS' => (bool) $features['admin_analytics'],
            'HAS_CRON' => (bool) $features['cron'],
            'HAS_META_REGISTRATION' => (bool) $features['meta_registration'],
            'HAS_BULK_ACTIONS' => (bool) $features['bulk_actions'],
            'HAS_SHORTCODE' => (bool) $features['shortcode'],
            'HAS_AJAX' => (bool) $features['ajax'],
            'HAS_CSS' => (bool) $features['has_css'],
            'HAS_JS' => (bool) $features['has_js'],
            'HAS_FRONTEND' => (bool) $features['frontend'],
        );
    }

    /**
     * Resolve {{#FLAG}} and {{^FLAG}} blocks against the flag map.
     *
     * A truthy flag keeps the {{#FLAG}} body and drops the {{^FLAG}} body;
     * a falsy flag does the reverse. Blocks of the same flag must not nest.
     *
     * @param string              $output     Rendered template body.
     * @param array<string, bool> $conditions Flag map.
     *
     * @return string
     */
    private static function _applyConditionals(
        string $output,
        array $conditions
    ): string {
        foreach ($conditions as $flag => $enabled) {
            $quoted = preg_quote($flag, '/');

            $output = (string) preg_replace_callback(
                '/[ \t]*\{\{#' . $quoted . '\}\}\n?(.*?)[ \t]*\{\{\/'
                    . $quoted . '\}\}\n?/s',
                static function (array $matches) use ($enabled): string {
                    return $enabled ? $matches[1] : '';
                },
                $output
            );

            $output = (string) preg_replace_callback(
                '/[ \t]*\{\{\^' . $quoted . '\}\}\n?(.*?)[ \t]*\{\{\/'
                    . $quoted . '\}\}\n?/s',
                static function (array $matches) use ($enabled): string {
                    return $enabled ? '' : $matches[1];
                },
                $output
            );
        }

        return $output;
    }

    /**
     * Convert bool to template string.
     *
     * @param bool $value Bool value.
     *
     * @return string
     */
    private static function _boolToPhp(bool $value): string
    {
        return $value ? 'true' : 'false';
    }

     /**
      * Apply template context and write file.
      *
      * @param string                $template   Template file.
      * @param string                $target     Output file.
      * @param array<string, string> $context    Replacement map.
      * @param array<string, bool>   $conditions Conditional-block flag map.
      *
      * @return void
      */
    private static function _writeFromTemplate(
        string $template,
        string $target,
        array $context,
        array $conditions = array()
    ): void {
        if (!file_exists($template)) {
            self::_fail("Template not found: {$template}");
        }

        $content = file_get_contents($template);
        $output = (string) $content;

        // Conditionals first: a dropped block must not leave its {{KEY}}
        // placeholders behind for the substitution pass to fill in.
        $output = self::_applyConditionals($output, $conditions);

        foreach ($context as $key => $value) {
            $output = str_replace('{{' . $key . '}}', $value, $output);
        }

        if (preg_match('/\{\{[#^\/]?[A-Z0-9_]+\}\}/', $output, $leftover)) {
            self::_fail(
                "Unresolved template placeholder {$leftover[0]} in {$template}"
            );
        }

        file_put_contents($target, $output);
    }

    /**
     * Create directory if it does not exist.
     *
     * @param string $dir Directory path.
     *
     * @return void
     */
    private static function _mkdirIfMissing(string $dir): void
    {
        if (!is_dir($dir)) {
            mkdir($dir, 0775, true);
        }
    }

    /**
     * Print error and exit.
     *
     * @param string $message Error message.
     *
     * @return never
     */
    private static function _fail(string $message)
    {
        fwrite(STDERR, "Error: {$message}\n");
        exit(1);
    }
}
